terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6" # 6.37.0 Ultima Version
    }
  }

  # backend "s3" {
  #   bucket         = "bucket-name" # previously created
  #   key            = "path/to/terraform.tfstate"
  #   region         = "region-name"
  #   encrypt        = true
  #   dynamodb_table = "dynamodb-table-name" # previously created LockID (s)
  #   #shared_credentials_file = "~/.aws/credentials"
  #   #profile                 = "profile-name"
  # }


}
