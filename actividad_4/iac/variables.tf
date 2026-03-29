variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "owner_name" {
  description = "Owner name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where NAT Instance will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}


variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
  default     = []
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  type        = list(string)
}

variable "route_table_ids" {
  description = "List of Route Table IDs for NAT routing"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks for SSH access (empty to disable)"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "default-projects-develop-kp"
}

variable "deploy_alb" {
  description = "Deploy ALB/Traefik instance"
  type        = bool
  default     = false
}

variable "database_user" {
  description = "Database username"
  type        = string
  default     = "postgres_user"
}

variable "database_password" {
  description = "Database password"
  type        = string
  default     = "postgres_pass"
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "todo_db"
}
