variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "actividad6"
}

variable "owner_name" {
  description = "Owner name"
  type        = string
  default     = "Francisco Briones"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.20.0.0/22"
}

variable "ssh_allowed_cidrs" {
  description = "List of CIDR blocks allowed to SSH into instances"
  type        = list(string)
  default = [
    "200.28.85.233/32",  # Melipilla
    "152.230.70.114/32", # DUOC
    "201.223.101.14/32"  # Santo Domingo
  ]
}

variable "instance_type_k3s" {
  description = "Instance type for k3s node"
  type        = string
  default     = "t3.micro"
}

variable "instance_type" {
  description = "Default instance type"
  type        = string
  default     = "t3.micro"
}


variable "iam_instance_profile" {
  description = "IAM Instance Profile name"
  type        = string
  default     = "LabInstanceProfile"
}

