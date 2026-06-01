variable "aws_region" {
  description = "AWS region where the ECS environment is created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Base name used for resources."
  type        = string
  default     = "tienda"
}

variable "environment" {
  description = "Environment name used for tags and resource names."
  type        = string
  default     = "ecs"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "azs" {
  description = "Availability zones used by the VPC."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "Private subnet CIDRs for ECS tasks."
  type        = list(string)
  default     = ["10.42.1.0/24", "10.42.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs for the ALB."
  type        = list(string)
  default     = ["10.42.101.0/24", "10.42.102.0/24"]
}

variable "image_tag" {
  description = "Container image tag deployed to ECS."
  type        = string
  default     = "ecs-v1"
}

variable "mysql_root_password" {
  description = "MySQL root password used by the sample app."
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "frontend_desired_count" {
  description = "Desired number of frontend tasks."
  type        = number
  default     = 2
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks."
  type        = number
  default     = 2
}

variable "db_desired_count" {
  description = "Desired number of database tasks."
  type        = number
  default     = 1
}

variable "force_delete_ecr" {
  description = "Allow Terraform to delete non-empty ECR repositories in lab environments."
  type        = bool
  default     = true
}
