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
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  # default     = "10.10.0.0/24" # Cantidad de ips disponibles: 256 (251 utilizables), Divido en 4 subredes de 64 ips cada una
  # default = "10.10.0.0/25" # Cantidad de ips disponibles: 128 (123 utilizables), Divido en 4 subredes de 32 ips cada una
  default = "10.10.0.0/26" # Cantidad de ips disponibles: 64 (59 utilizables), Divido en 4 subredes de 16 ips cada una
  # default = "10.10.0.0/27" # Cantidad de ips disponibles: 32 (27 utilizables), Divido en 4 subredes de 8 ips cada una
  # default = "10.10.0.0/28" # Cantidad de ips disponibles: 16 (11 utilizables), Divido en 4 subredes de 4 ips cada una

}

variable "ssh_allowed_cidrs" {
  description = "List of CIDR blocks allowed to SSH into instances"
  type        = list(string)
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

