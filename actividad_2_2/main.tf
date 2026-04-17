locals {
  name_prefix = "${var.project_name}-${var.environment}"
  vpc_cidr    = "10.10.0.0/22"
  azs         = ["us-east-1a", "us-east-1b"]
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
  source_dir  = "${path.module}/pet_store"
  output_path = "${path.module}/pet_store.zip"
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
  ]

  tags = {
    Name = "${local.name_prefix}-lab-sg"
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

  user_data = <<-EOF
              #!/bin/bash
              # 1. Extract application if present
              APP_ZIP_B64="${filebase64(data.archive_file.app_single.output_path)}"
              if [ -n "$APP_ZIP_B64" ]; then
                apt-get update
                apt-get install -y unzip
                mkdir -p /home/ubuntu/app
                echo "$APP_ZIP_B64" | base64 -d > /home/ubuntu/app.zip
                unzip /home/ubuntu/app.zip -d /home/ubuntu/app
                chown -R ubuntu:ubuntu /home/ubuntu/app
              fi

              # 2. Run custom user data script
              apt-get install -y docker.io docker-compose apache2-utils
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu

              # Corremos la app con compose
              cd /home/ubuntu/app
              docker-compose up -d
              EOF

  tags = {
    Name = "${local.name_prefix}-compose-instance"
  }
}

