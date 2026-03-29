output "nat_instance_public_ip" {
  description = "Public IP of the NAT Instance"
  value = {
    nat_instance_public_ip = module.nat_instance.nat_instance_public_ip
    alb_instance_public_ip = var.deploy_alb ? module.alb_instance[0].traefik_instance_public_ip : null
  }
}

output "nat_instance_private_ip" {
  description = "Private IP of the NAT Instance"
  value = {
    nat_instance_private_ip = module.nat_instance.nat_instance_private_ip
    alb_instance_private_ip = var.deploy_alb ? module.alb_instance[0].traefik_instance_private_ip : null
  }
}

output "nat_instance_id" {
  description = "ID of the NAT Instance"
  value = {
    nat_instance_id = module.nat_instance.nat_instance_id
    alb_instance_id = var.deploy_alb ? module.alb_instance[0].traefik_instance_id : null
  }
}

output "app_instances_public_ips" {
  description = "Public IPs of application instances"
  value = {
    frontend = module.frontend_instance.instance_public_ip
  }
}

output "app_instances_private_ips" {
  description = "Private IPs of application instances"
  value = {
    frontend = module.frontend_instance.instance_private_ip
    backend  = module.backend_instance.instance_private_ip
    database = module.database_instance.instance_private_ip
  }
}

output "app_instance_ids" {
  description = "IDs of application instances"
  value = {
    frontend = module.frontend_instance.instance_id
    backend  = module.backend_instance.instance_id
    database = module.database_instance.instance_id
  }
}
