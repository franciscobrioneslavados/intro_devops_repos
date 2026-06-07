locals {
  vpc_cidr    = var.vpc_cidr
  azs         = ["us-east-1a", "us-east-1b"]
  name_prefix = "${var.project_name}-${var.environment}"

  arn_task_execution_role = "arn:aws:iam::891377192530:role/LabRole"
}

data "aws_caller_identity" "current" {}

# ==============================================================================
# VPC (Virtual Private Cloud)
# ==============================================================================

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

  create_igw              = true  # Create Internet Gateway
  enable_nat_gateway      = false # Using custom NAT instance module
  single_nat_gateway      = true  # Group private subnets into one route table
  enable_vpn_gateway      = false # Not using VPN Gateway
  enable_dns_hostnames    = true  # Enable DNS hostnames
  enable_dns_support      = true  # Enable DNS support
  map_public_ip_on_launch = true  # Enable public IP on launch

  public_route_table_tags = {
    Name = "${local.name_prefix}-public-rt"
  }
  private_route_table_tags = {
    Name = "${local.name_prefix}-private-rt"
  }
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
  instance_type        = "t3.micro"
  ssh_allowed_cidrs    = []
  os_type              = "amazon-linux-2" # or "ubuntu"

  depends_on = [module.vpc]
}



# ==============================================================================
# ECR (Elastic Container Registry)
# ==============================================================================

resource "aws_ecr_repository" "app" {
  for_each = toset(["frontend", "backend", "db"])

  name                 = "${local.name_prefix}-${each.key}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# ==============================================================================
# CloudWatch Log Groups
# ==============================================================================

resource "aws_cloudwatch_log_group" "app" {
  for_each = toset(["frontend", "backend", "db"])

  name              = "/ecs/${local.name_prefix}-${each.key}"
  retention_in_days = 7
}

# ==============================================================================
# ECS Cluster
# ==============================================================================

resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ==============================================================================
# Security Group para ALB
# ==============================================================================

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb"
  description = "Allow public HTTP traffic to the application ALB."
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb_target_group" "frontend" {
  name        = "${local.name_prefix}-frontend"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    timeout             = 5
    unhealthy_threshold = 3
  }
}

resource "aws_service_discovery_private_dns_namespace" "db_ns" {
  name        = "${local.name_prefix}-ns"
  vpc         = module.vpc.vpc_id
  description = "Private DNS namespace for DB service discovery"
}

resource "aws_service_discovery_service" "db" {
  name = "db"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.db_ns.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ==============================================================================
# Servicios de ECS y Definición de Tareas (Modularizados para Reutilización)
# ==============================================================================

# 1. API Backend Service
module "backend_service" {
  source = "./modules/ecs-service"

  name                    = "${local.name_prefix}-backend"
  cluster_id              = aws_ecs_cluster.this.id
  cluster_name            = aws_ecs_cluster.this.name
  vpc_id                  = module.vpc.vpc_id
  subnets                 = module.vpc.private_subnets
  task_execution_role_arn = local.arn_task_execution_role

  cpu             = 512
  memory          = 1024
  container_image = "891377192530.dkr.ecr.us-east-1.amazonaws.com/intro-devops-lab-backend:ecs-v1"
  container_port  = 8080
  log_group_name  = aws_cloudwatch_log_group.app["backend"].name
  aws_region      = var.aws_region
  desired_count   = 2 # Cantidad deseada de tareas corriendo

  environment_variables = [
    {
      name  = "PORT"
      value = "8080"
    },
    {
      name  = "DB_HOST"
      value = "${aws_service_discovery_service.db.name}.${aws_service_discovery_private_dns_namespace.db_ns.name}"
    },
    {
      name  = "DB_USER"
      value = "root"
    },
    {
      name  = "DB_PASSWORD"
      value = var.mysql_root_password
    },
    {
      name  = "DB_NAME"
      value = "tienda_perritos"
    },
    {
      name  = "DB_PORT"
      value = 3306
    }
  ]

  health_check_command = ["CMD-SHELL", "wget -qO- http://localhost:8080/api/health || exit 1"]

  enable_autoscaling = true
  min_capacity       = 1  # Autoscaling: Mínimo 1 tarea corriendo
  max_capacity       = 3  # Autoscaling: Máximo 3 tareas corriendo
  cpu_target_value   = 80 # Si el uso de CPU supera el 80%, se agrega una tarea

}

# 2. Base de Datos (MySQL) Service
module "db_service" {
  source = "./modules/ecs-service"

  name                    = "${local.name_prefix}-db"
  cluster_id              = aws_ecs_cluster.this.id
  cluster_name            = aws_ecs_cluster.this.name
  vpc_id                  = module.vpc.vpc_id
  subnets                 = module.vpc.private_subnets
  task_execution_role_arn = local.arn_task_execution_role

  cpu             = 512
  memory          = 1024
  container_image = "891377192530.dkr.ecr.us-east-1.amazonaws.com/intro-devops-lab-db:ecs-v1"
  container_port  = 3306
  log_group_name  = aws_cloudwatch_log_group.app["db"].name
  aws_region      = var.aws_region
  desired_count   = 2

  environment_variables = [
    {
      name  = "MYSQL_ROOT_PASSWORD"
      value = var.mysql_root_password
    }
  ]

  allowed_ingress_security_groups = [
    {
      security_group_id = module.backend_service.security_group_id
      port              = 3306
    }
  ]

  enable_autoscaling = true
  min_capacity       = 1  # Autoscaling: Mínimo 1 tarea corriendo
  max_capacity       = 3  # Autoscaling: Máximo 3 tareas corriendo
  cpu_target_value   = 80 # Si el uso de CPU supera el 80%, se agrega una tarea

}

# 3. Frontend Web Service
module "frontend_service" {
  source = "./modules/ecs-service"

  name                    = "${local.name_prefix}-frontend"
  cluster_id              = aws_ecs_cluster.this.id
  cluster_name            = aws_ecs_cluster.this.name
  vpc_id                  = module.vpc.vpc_id
  subnets                 = module.vpc.private_subnets
  task_execution_role_arn = local.arn_task_execution_role

  cpu             = 256
  memory          = 512
  container_image = "891377192530.dkr.ecr.us-east-1.amazonaws.com/intro-devops-lab-frontend:ecs-v1"
  container_port  = 80
  log_group_name  = aws_cloudwatch_log_group.app["frontend"].name
  aws_region      = var.aws_region
  desired_count   = 2

  health_check_command = ["CMD-SHELL", "wget -qO- http://localhost/ || exit 1"]
  target_group_arn     = aws_lb_target_group.frontend.arn

  allowed_ingress_security_groups = [
    {
      security_group_id = aws_security_group.public_lb.id
      port              = 80
    }
  ]

  enable_autoscaling = true
  min_capacity       = 1  # Autoscaling: Mínimo 1 tarea corriendo
  max_capacity       = 3  # Autoscaling: Máximo 3 tareas corriendo
  cpu_target_value   = 70 # Si el uso de CPU supera el 70%, se agrega una tarea

  depends_on = [
    aws_lb_listener.http
  ]
}
