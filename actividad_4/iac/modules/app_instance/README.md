# App Instance Module

This module creates an EC2 instance with Docker for running application containers.

## Resources Created

- EC2 Instance (t2.micro by default)
- EBS Volume for root filesystem (8GB)
- EBS Volume for data (8GB)

## Features

- Ubuntu 22.04 LTS
- Docker and Docker Compose installed via user_data
- Automatic pull and run of Docker image from Docker Hub
- Support for environment variables

## Usage

```hcl
module "frontend_instance" {
  source = "./modules/app_instance"

  project_name        = "my-project"
  environment         = "dev"
  owner_name          = "My Name"
  instance_type       = "t2.micro"
  subnet_id           = "subnet-12345678"
  key_name            = "my-key-pair"
  security_group_id   = "sg-12345678"
  docker_hub_username = "my-dockerhub-user"
  app_name            = "frontend"
  exposed_port        = 80
}
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| project_name | Project name | - |
| environment | Environment (dev, staging, prod) | - |
| owner_name | Owner name | - |
| instance_type | EC2 instance type | t2.micro |
| subnet_id | Subnet ID | - |
| key_name | SSH key pair name | - |
| security_group_id | Security group ID | - |
| docker_hub_username | Docker Hub username | - |
| app_name | Application name | - |
| exposed_port | Container exposed port | - |
| docker_env_vars | Environment variables for container | "" |
| ebs_volume_size | Root EBS volume size (GB) | 8 |
| ebs_data_volume_size | Data EBS volume size (GB) | 8 |

## Outputs

| Output | Description |
|--------|-------------|
| instance_id | EC2 instance ID |
| instance_public_ip | Public IP (if in public subnet) |
| instance_private_ip | Private IP |
| instance_public_dns | Public DNS |
| instance_private_dns | Private DNS |
| ebs_data_volume_id | Data EBS volume ID |

## User Data Script

The instance automatically:
1. Updates apt and installs Docker + Docker Compose
2. Starts Docker daemon
3. Pulls the specified image from Docker Hub
4. Runs the container with the specified port and environment variables
