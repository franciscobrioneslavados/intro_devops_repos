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
  description = "VPC ID"
  type        = string
}
