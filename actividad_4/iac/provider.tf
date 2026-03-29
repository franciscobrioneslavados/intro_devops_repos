terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "personal"

  default_tags {
    tags = {
      Environment = var.environment
      ProjectName = var.project_name
      OwnerName   = var.owner_name
      ManagedBy   = "Terraform"
    }
  }
}
