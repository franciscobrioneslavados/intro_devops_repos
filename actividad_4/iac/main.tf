locals {
  database_user_data = base64encode(templatefile("${path.module}/templates/user_data_database.tpl", {
    database_user     = var.database_user
    database_password = var.database_password
    database_name     = var.database_name
  }))
  backend_user_data = base64encode(templatefile("${path.module}/templates/user_data_backend.tpl", {
    database_url = "postgresql://${var.database_user}:${var.database_password}@${module.database_instance.instance_private_ip}:5432/${var.database_name}"
    # cors_frontend_url = "http://${module.frontend_instance.instance_public_ip}"
  }))
  frontend_user_data = base64encode(templatefile("${path.module}/templates/user_data_frontend.tpl", {
    backend_ip = module.backend_instance.instance_private_ip
  }))
}

module "nat_instance" {
  source = "git::https://github.com/franciscobrioneslavados/terraform-aws-nat-instance.git//.?ref=v1.2.2"

  vpc_id               = var.vpc_id
  public_subnet_ids    = var.public_subnet_ids
  private_subnet_cidrs = var.private_subnet_cidrs
  route_table_ids      = var.route_table_ids
  project_name         = "nat-instance"
  environment          = var.environment
  owner_name           = var.owner_name
  instance_type        = var.instance_type
  ssh_allowed_cidrs    = var.ssh_allowed_cidrs
  key_name             = var.key_name
}

module "alb_instance" {
  count  = var.deploy_alb ? 1 : 0
  source = "git::https://github.com/franciscobrioneslavados/terraform-aws-traefik-instance.git//.?ref=v1.5.2"

  vpc_id            = var.vpc_id
  public_subnet_ids = var.public_subnet_ids
  project_name      = "alb-instance"
  environment       = var.environment
  owner_name        = var.owner_name
  instance_type     = var.instance_type
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
  key_name          = var.key_name
}

module "app_security_groups" {
  source = "./modules/sg"

  project_name          = var.project_name
  environment           = var.environment
  owner_name            = var.owner_name
  vpc_id                = var.vpc_id
  alb_security_group_id = var.deploy_alb ? module.alb_instance[0].traefik_security_group_id : null
}

module "database_instance" {
  source = "./modules/app_instance"

  project_name      = var.project_name
  environment       = var.environment
  owner_name        = var.owner_name
  instance_type     = var.instance_type
  subnet_id         = var.database_subnet_ids[0]
  key_name          = var.key_name
  security_group_id = module.app_security_groups.database_security_group_id
  app_name          = "database"
  exposed_port      = 5432
  user_data         = local.database_user_data

  depends_on = [module.nat_instance]
}

module "backend_instance" {
  source = "./modules/app_instance"

  project_name      = var.project_name
  environment       = var.environment
  owner_name        = var.owner_name
  instance_type     = var.instance_type
  subnet_id         = var.private_subnet_ids[0]
  key_name          = var.key_name
  security_group_id = module.app_security_groups.backend_security_group_id
  app_name          = "backend"
  exposed_port      = 3000
  swagger_enabled   = true
  user_data         = local.backend_user_data

  depends_on = [module.database_instance]
}

module "frontend_instance" {
  source = "./modules/app_instance"

  project_name                = var.project_name
  environment                 = var.environment
  owner_name                  = var.owner_name
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[0]
  key_name                    = var.key_name
  associate_public_ip_address = true
  security_group_id           = module.app_security_groups.frontend_security_group_id
  app_name                    = "frontend"
  exposed_port                = 80
  backend_private_ip          = module.backend_instance.instance_private_ip
  user_data                   = local.frontend_user_data

  depends_on = [module.backend_instance]
}
