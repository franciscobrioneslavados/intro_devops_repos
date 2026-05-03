output "frontend_instances_info" {
  value = {
    instance_id = module.frontend_host.instance_id[0]
    public_ip   = module.frontend_host.public_ips[0]
    curl_test   = "curl -I http://${module.frontend_host.public_ips[0]}/"
    ssm_connect = "aws ssm start-session --target ${module.frontend_host.instance_id[0]}"
  }
}

output "backend_instances_info" {
  value = {
    instance_id = module.backend_host.instance_id[0]
    private_ip  = module.backend_host.private_ips[0]
    ssm_connect = "aws ssm start-session --target ${module.backend_host.instance_id[0]}"
  }
}

output "db_instances_info" {
  value = {
    instance_id = module.db_host.instance_id[0]
    private_ip  = module.db_host.private_ips[0]
    ssm_connect = "aws ssm start-session --target ${module.db_host.instance_id[0]}"
  }
}

output "deployment_info" {
  value = {
    registry_used = var.container_registry
    images        = local.images
  }
}
