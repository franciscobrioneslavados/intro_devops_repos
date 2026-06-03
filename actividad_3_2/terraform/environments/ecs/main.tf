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

# ==============================================================================
# ALB (Application Load Balancer)
# ==============================================================================

resource "aws_lb" "this" {
  name               = local.name_prefix
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
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

resource "aws_lb_target_group" "backend" {
  name        = "${local.name_prefix}-backend"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/api/health"
    timeout             = 5
    unhealthy_threshold = 3
  }
}

resource "aws_lb" "db_nlb" {
  name               = "${local.name_prefix}-db-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = module.vpc.private_subnets
  tags = {
    Name = "${local.name_prefix}-db-nlb"
  }
}

resource "aws_lb_target_group" "db" {
  name        = "${local.name_prefix}-db-tg"
  port        = 3306
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check {
    protocol = "TCP"
    port     = "3306"
    interval = 30
    timeout  = 10
  }
}

resource "aws_lb_listener" "db" {
  load_balancer_arn = aws_lb.db_nlb.arn
  port              = 3306
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.db.arn
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

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
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
  desired_count   = 2

  environment_variables = [
    {
      name  = "PORT"
      value = "8080"
    },
    {
      name  = "DB_HOST"
      value = "${aws_lb.db_nlb.dns_name}"
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
  target_group_arn     = aws_lb_target_group.backend.arn

  allowed_ingress_security_groups = [
    {
      security_group_id = aws_security_group.alb.id
      port              = 8080
    }
  ]

  enable_autoscaling = true
  min_capacity       = 2
  max_capacity       = 10
  cpu_target_value   = 70

  depends_on = [
    aws_lb_listener_rule.api
  ]
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

  target_group_arn = aws_lb_target_group.db.arn

  allowed_ingress_security_groups = [
    {
      security_group_id = module.backend_service.security_group_id
      port              = 3306
    }
  ]
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
      security_group_id = aws_security_group.alb.id
      port              = 80
    }
  ]

  enable_autoscaling = true
  min_capacity       = 2
  max_capacity       = 6
  cpu_target_value   = 60

  depends_on = [
    aws_lb_listener.http
  ]
}

# Regla adicional para permitir health checks del NLB a la Base de Datos
resource "aws_vpc_security_group_ingress_rule" "db_nlb_health_check" {
  security_group_id = module.db_service.security_group_id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "tcp"
}

# VPC Endpoints for ECR (Suggested by user)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ecr_endpoints.id]
  subnet_ids          = module.vpc.private_subnets
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ecr_endpoints.id]
  subnet_ids          = module.vpc.private_subnets
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids
}

resource "aws_security_group" "ecr_endpoints" {
  name        = "${local.name_prefix}-ecr-endpoints-sg"
  description = "Security group for ECR VPC Endpoints"
  vpc_id      = module.vpc.vpc_id


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-ecr-endpoints-sg"
  }
}
