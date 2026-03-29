# Security Groups Module

This module creates security groups for the application tier architecture.

## Security Groups Created

| Name | Description | Ports |
|------|-------------|-------|
| frontend | Frontend application security group | 80, 443 |
| backend | Backend application security group | 3000 |
| database | Database security group | 5432 |

## Security Group Rules

### Frontend
- **Ingress**: HTTP (80) from 0.0.0.0/0
- **Ingress**: HTTPS (443) from 0.0.0.0/0
- **Egress**: All traffic to 0.0.0.0/0

### Backend
- **Ingress**: Port 3000 from Frontend security group
- **Egress**: All traffic to 0.0.0.0/0

### Database
- **Ingress**: Port 5432 from Backend security group
- **Egress**: All traffic to 0.0.0.0/0

## Usage

```hcl
module "sg" {
  source = "./modules/sg"

  project_name = "my-project"
  environment  = "dev"
  owner_name   = "My Name"
  vpc_id       = "vpc-12345678"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| frontend_security_group_id | ID of frontend security group |
| backend_security_group_id | ID of backend security group |
| database_security_group_id | ID of database security group |
