output "compose_host_public_ip" {
  value = module.compose_host.public_ips[0]
}

output "ssh_command_compose" {
  value = "ssh -i ${var.project_name}-${var.environment}-key.pem ubuntu@${module.compose_host.public_ips[0]}"
}

output "test_compose_host" {
  value = "curl -i http://${module.compose_host.public_ips[0]}:8080/"
}

