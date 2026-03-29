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

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be deployed"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "app_name" {
  description = "Application name (frontend, backend, database)"
  type        = string
}

variable "exposed_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "ebs_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 8
}

variable "ebs_data_volume_size" {
  description = "Data EBS volume size in GB"
  type        = number
  default     = 8
}

variable "backend_private_ip" {
  description = "Backend private IP for frontend to connect to"
  type        = string
  default     = ""
}

variable "swagger_enabled" {
  description = "Enable swagger UI for backend"
  type        = bool
  default     = false
}

variable "associate_public_ip_address" {
  description = "Associate public IP address to the instance"
  type        = bool
  default     = false
}


variable "user_data" {
  description = "User data for the instance"
  type        = string
}
