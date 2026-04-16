locals {
  name_prefix = "${var.project_name}-${var.environment}"
  vpc_cidr    = "10.10.0.0/22"
  azs         = ["us-east-1a", "us-east-1b"]

  k3s_user_data = templatefile("${path.module}/templates/k3s-user-data.tpl", {
    node_name = "${local.name_prefix}-k3s-master"
  })
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = "${local.name_prefix}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, 2, i)]
  public_subnets  = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, 2, i + length(local.azs))]

  private_subnet_names = [for az in local.azs : "${local.name_prefix}-private-${az}"]
  public_subnet_names  = [for az in local.azs : "${local.name_prefix}-public-${az}"]

  public_route_table_tags = {
    Name = "${local.name_prefix}-public-rt"
  }
  private_route_table_tags = {
    Name = "${local.name_prefix}-private-rt"
  }

  # Tags for Internet Gateway
  igw_tags = {
    Name = "${local.name_prefix}-igw"
  }

  create_igw              = true  # Create Internet Gateway
  enable_nat_gateway      = false # Using custom NAT instance module
  single_nat_gateway      = true  # Group private subnets into one route table
  enable_vpn_gateway      = false # Not using VPN Gateway
  enable_dns_hostnames    = true  # Enable DNS hostnames
  enable_dns_support      = true  # Enable DNS support
  map_public_ip_on_launch = true  # Enable public IP on launch

}

module "nat_instance" {
  source = "git::https://github.com/franciscobrioneslavados/terraform-aws-nat-instance.git//.?ref=v1.3.0"

  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnets
  private_subnet_cidrs = module.vpc.private_subnets_cidr_blocks
  route_table_ids      = module.vpc.private_route_table_ids
  project_name         = "${local.name_prefix}-nat"
  environment          = var.environment
  owner_name           = var.owner_name
  instance_type        = var.instance_type
  ssh_allowed_cidrs    = var.ssh_allowed_cidrs
  key_name             = aws_key_pair.poc2_key.key_name
  os_type              = "amazon-linux-2" # or "ubuntu"

  depends_on = [module.vpc]
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "poc2_key" {
  key_name   = "${local.name_prefix}-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "${path.module}/${local.name_prefix}-key.pem"
  file_permission = "0400"
}

data "archive_file" "app_single" {
  type        = "zip"
  source_dir  = "${path.module}/app_single"
  output_path = "${path.module}/app_single.zip"
}

data "archive_file" "app_db" {
  type        = "zip"
  source_dir  = "${path.module}/app_db"
  output_path = "${path.module}/app_db.zip"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# TODO: EBS GP3
data "aws_ami" "amazon_linux_2023" {
  ## New Version Version 2023.10.20260105
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "lab_sg" {
  source = "./modules/security_group"

  name        = "${local.name_prefix}-lab-sg"
  description = "Security group for Docker/Podman labs"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
      description = "SSH access"
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = var.ssh_allowed_cidrs
      description = "ICMP"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Web apps port"
    },
    {
      from_port   = 2377
      to_port     = 2377
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
      description = "Docker Swarm cluster management"
    },
    {
      from_port   = 7946
      to_port     = 7946
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
      description = "Docker Swarm node communication (TCP)"
    },
    {
      from_port   = 7946
      to_port     = 7946
      protocol    = "udp"
      cidr_blocks = [local.vpc_cidr]
      description = "Docker Swarm node communication (UDP)"
    },
    {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      cidr_blocks = [local.vpc_cidr]
      description = "Docker Swarm overlay network traffic"
    }
  ]

  tags = {
    Name = "${local.name_prefix}-lab-sg"
  }
}

module "docker_host" {
  source = "./modules/ec2"

  name                 = "${local.name_prefix}-docker-instance"
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = module.vpc.public_subnets[0]
  security_group_ids   = [module.lab_sg.security_group_id]
  key_name             = aws_key_pair.poc2_key.key_name
  iam_instance_profile = var.iam_instance_profile
  app_zip_base64       = filebase64(data.archive_file.app_single.output_path)

  user_data = <<-EOF
              apt-get update
              apt-get install -y docker.io docker-compose apache2-utils
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu

              # Obtener metadata de la instancia
              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              INST_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
              AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
              PRIV_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

              # Corremos la app una vez extraida
              cd /home/ubuntu/app
              docker build -t myapp .
              docker run -d --name myapp -p 8080:80 \
                -e NODE_NAME="DockerHost" \
                -e INSTANCE_ID="$INST_ID" \
                -e AVAILABILITY_ZONE="$AZ" \
                -e PRIVATE_IP="$PRIV_IP" \
                myapp
              EOF

  tags = {
    Name = "${local.name_prefix}-docker-instance"
  }
}

module "compose_host" {
  source = "./modules/ec2"

  name                 = "${local.name_prefix}-compose-instance"
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = module.vpc.public_subnets[0]
  security_group_ids   = [module.lab_sg.security_group_id]
  key_name             = aws_key_pair.poc2_key.key_name
  iam_instance_profile = var.iam_instance_profile
  app_zip_base64       = filebase64(data.archive_file.app_db.output_path)

  user_data = <<-EOF
              apt-get update
              apt-get install -y docker.io docker-compose apache2-utils
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu

              # Obtener metadata de la instancia
              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              INST_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
              AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
              PRIV_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

              # Exportar para docker-compose
              export NODE_NAME="ComposeHost"
              export INSTANCE_ID="$INST_ID"
              export AVAILABILITY_ZONE="$AZ"
              export PRIVATE_IP="$PRIV_IP"

              # Corremos la app con compose
              cd /home/ubuntu/app
              docker-compose up -d
              EOF

  tags = {
    Name = "${local.name_prefix}-compose-instance"
  }
}

module "podman_host" {
  source = "./modules/ec2"

  name                 = "${local.name_prefix}-podman-instance"
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = module.vpc.public_subnets[0]
  security_group_ids   = [module.lab_sg.security_group_id]
  key_name             = aws_key_pair.poc2_key.key_name
  iam_instance_profile = var.iam_instance_profile
  app_zip_base64       = filebase64(data.archive_file.app_single.output_path)

  user_data = <<-EOF
              apt-get update
              apt-get install -y podman

              # Obtener metadata de la instancia
              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              INST_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
              AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
              PRIV_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

              # Wait for app and run with podman
              sleep 10
              cd /home/ubuntu/app
              podman build -t myapp .
              podman run -d --name myapp -p 8080:80 \
                -e NODE_NAME="PodmanHost" \
                -e INSTANCE_ID="$INST_ID" \
                -e AVAILABILITY_ZONE="$AZ" \
                -e PRIVATE_IP="$PRIV_IP" \
                myapp
              EOF

  tags = {
    Name = "${local.name_prefix}-podman-instance"
  }
}

module "swarm_nodes" {
  source = "./modules/ec2"

  instance_count       = 2
  name                 = "${local.name_prefix}-swarm-instance"
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = module.vpc.public_subnets[1]
  security_group_ids   = [module.lab_sg.security_group_id]
  key_name             = aws_key_pair.poc2_key.key_name
  iam_instance_profile = var.iam_instance_profile
  app_zip_base64       = filebase64(data.archive_file.app_single.output_path)

  user_data = <<-EOF
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "${local.name_prefix}-swarm-instance"
  }
}

module "sg_k3s" {
  source = "./modules/security_group"

  name        = "${local.name_prefix}-k3s-sg"
  description = "Security group for k3s server"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
      description = "SSH access"
    },
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
      description = "k3s API Server"
    }
  ]

  tags = {
    Name = "${local.name_prefix}-k3s-sg"
  }
}

module "k3s_server" {
  source = "./modules/ec2"

  name                 = "${local.name_prefix}-k3s-instance"
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type_k3s
  subnet_id            = module.vpc.public_subnets[0]
  security_group_ids   = [module.sg_k3s.security_group_id]
  key_name             = aws_key_pair.poc2_key.key_name
  iam_instance_profile = var.iam_instance_profile

  user_data = local.k3s_user_data

  tags = {
    Name = "${local.name_prefix}-k3s-instance"
  }
}


