locals {
  project_name = var.project_name
  environment  = var.environment
  owner_name   = var.owner_name
}

resource "aws_security_group" "frontend" {
  name        = "${local.project_name}-${local.environment}-sg-frontend"
  description = "Security group for frontend application"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.project_name}-${local.environment}-sg-frontend"
    Project     = local.project_name
    Environment = local.environment
    Owner       = local.owner_name
  }
}

resource "aws_security_group_rule" "frontend_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP access"
  security_group_id = aws_security_group.frontend.id
}

resource "aws_security_group_rule" "frontend_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS access"
  security_group_id = aws_security_group.frontend.id
}

resource "aws_security_group_rule" "frontend_egress_to_backend" {
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend.id
  description              = "Access to backend on port 3000"
  security_group_id        = aws_security_group.frontend.id
}

resource "aws_security_group_rule" "frontend_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound"
  security_group_id = aws_security_group.frontend.id
}

resource "aws_security_group_rule" "frontend_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "SSH access"
  security_group_id = aws_security_group.frontend.id
}

resource "aws_security_group" "backend" {
  name        = "${local.project_name}-${local.environment}-sg-backend"
  description = "Security group for backend application"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.project_name}-${local.environment}-sg-backend"
    Project     = local.project_name
    Environment = local.environment
    Owner       = local.owner_name
  }
}

resource "aws_security_group_rule" "backend_ingress" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend.id
  description              = "Access from frontend"
  security_group_id        = aws_security_group.backend.id
}

resource "aws_security_group_rule" "backend_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP for swagger"
  security_group_id = aws_security_group.backend.id
}

resource "aws_security_group_rule" "backend_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS for swagger"
  security_group_id = aws_security_group.backend.id
}

resource "aws_security_group_rule" "backend_egress_to_database" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.database.id
  description              = "Access to database on port 5432"
  security_group_id        = aws_security_group.backend.id
}

resource "aws_security_group_rule" "backend_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound"
  security_group_id = aws_security_group.backend.id
}

resource "aws_security_group_rule" "backend_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend.id
  description              = "SSH from frontend"
  security_group_id        = aws_security_group.backend.id
}

resource "aws_security_group" "database" {
  name        = "${local.project_name}-${local.environment}-sg-database"
  description = "Security group for database application"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.project_name}-${local.environment}-sg-database"
    Project     = local.project_name
    Environment = local.environment
    Owner       = local.owner_name
  }
}

resource "aws_security_group_rule" "database_ingress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend.id
  description              = "Access from backend"
  security_group_id        = aws_security_group.database.id
}

resource "aws_security_group_rule" "database_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound"
  security_group_id = aws_security_group.database.id
}

resource "aws_security_group_rule" "database_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend.id
  description              = "SSH from frontend"
  security_group_id        = aws_security_group.database.id
}
