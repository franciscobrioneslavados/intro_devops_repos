variable "aws_region" {
  description = "AWS region to use for authentication"
}
variable "aws_profile" {
  description = "AWS profile to use for authentication"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "subnet_newbits" {
  type        = number
  description = "Number of bits to add to the VPC CIDR for creating subnets (e.g., 8 gives /28 for a /20 VPC, 4 gives /24)"
  default     = 4
}

variable "instance_tenancy" {
  type        = string
  description = "Instance tenancy for the VPC (default = multi-tenant, dedicated = single-tenant)"
  default     = "default"
}

variable "nat_per_az" {
  type        = bool
  description = "NAT Gateway per AZ true = multiple NAT Gateways, false = one NAT Gateway"
  validation {
    condition     = contains([true, false], var.nat_per_az)
    error_message = "NAT Gateway per AZ must be true or false"
  }
  default = false
}

variable "stage" {
  type        = string
  description = "Deployment stage/environment name"
  validation {
    condition     = contains(["dev", "qa", "prd"], var.stage)
    error_message = "Stage must be dev, qa, or prd"
  }
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "organizational_unit" {
  type        = string
  description = "Comunity or Gobernance Name"
}

variable "description" {
  type        = string
  description = "The description of the project"
}

variable "managed_by" {
  description = "Managed By automation tool name or team"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
