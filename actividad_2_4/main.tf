locals {
  name_prefix = "${var.project_name}-${var.environment}"
  # Limpiamos el CIDR local para usar la variable
  vpc_cidr = var.vpc_cidr
  azs      = ["us-east-1a", "us-east-1b"]

  images = {
    for k in ["frontend", "backend", "db"] : k => try(
      var.container_registry == "ecr" ? "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.name_prefix}-${k}:latest" : (
        var.container_registry == "github" ? "ghcr.io/${var.github_username}/${local.name_prefix}-${k}:latest" : "${var.dockerhub_username}/${local.name_prefix}-${k}:latest"
      ),
      ""
    )
  }
}

data "aws_caller_identity" "current" {}

# ECR repositories are now managed by the CI/CD setup job to avoid circular dependencies
# resource "aws_ecr_repository" "app" {
#   for_each             = toset(["frontend", "backend", "db"])
#   name                 = "${local.name_prefix}-${each.key}"
#   image_tag_mutability = "MUTABLE"
#   force_delete         = true
#
#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

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

# --- Security Groups por Tier ---

module "frontend_sg" {
  source = "./modules/security_group"

  name        = "${local.name_prefix}-frontend-sg"
  description = "Security group for Frontend (Public)"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
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
      description = "HTTP access from world"
    }
  ]
}

module "backend_sg" {
  source = "./modules/security_group"

  name        = "${local.name_prefix}-backend-sg"
  description = "Security group for Backend (Private)"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port          = -1
      to_port            = -1
      protocol           = "icmp"
      security_group_ids = [module.frontend_sg.security_group_id]
      description        = "ICMP access"
    },
    {
      from_port          = 3001
      to_port            = 3001
      protocol           = "tcp"
      security_group_ids = [module.frontend_sg.security_group_id]
      description        = "Backend access from Frontend SG"
    }
  ]
}

module "db_sg" {
  source = "./modules/security_group"

  name        = "${local.name_prefix}-db-sg"
  description = "Security group for Database (Private)"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port          = -1
      to_port            = -1
      protocol           = "icmp"
      security_group_ids = [module.backend_sg.security_group_id]
      description        = "ICMP access"
    },
    {
      from_port          = 3306
      to_port            = 3306
      protocol           = "tcp"
      security_group_ids = [module.backend_sg.security_group_id]
      description        = "MySQL access from Backend SG"
    }
  ]
}

# --- Instancias de la Aplicación ---

module "db_host" {
  source = "./modules/ec2"

  name                 = "${local.name_prefix}-db"
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = module.vpc.private_subnets[0]
  security_group_ids   = [module.db_sg.security_group_id]
  iam_instance_profile = var.iam_instance_profile

  user_data = templatefile("${path.module}/templates/database.tpl", {
    image_url          = try(local.images["db"], "")
    container_registry = var.container_registry
  })

  tags = { Layer = "database" }
}

module "backend_host" {
  source = "./modules/ec2"

  name                 = "${local.name_prefix}-backend"
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = module.vpc.private_subnets[1]
  security_group_ids   = [module.backend_sg.security_group_id]
  iam_instance_profile = var.iam_instance_profile

  user_data = templatefile("${path.module}/templates/backend.tpl", {
    image_url          = try(local.images["backend"], "")
    container_registry = var.container_registry
    db_host            = module.db_host.private_ips[0]
  })

  tags       = { Layer = "backend" }
  depends_on = [module.db_host]
}

module "frontend_host" {
  source = "./modules/ec2"

  name                 = "${local.name_prefix}-frontend"
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = module.vpc.public_subnets[0]
  security_group_ids   = [module.frontend_sg.security_group_id]
  iam_instance_profile = var.iam_instance_profile

  user_data = templatefile("${path.module}/templates/frontend.tpl", {
    image_url          = try(local.images["frontend"], "")
    container_registry = var.container_registry
    backend_host       = module.backend_host.private_ips[0]
  })

  tags       = { Layer = "frontend" }
  depends_on = [module.backend_host]
}

