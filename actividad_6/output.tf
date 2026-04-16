output "docker_host_public_ip" {
  value = module.docker_host.public_ips[0]
}

output "podman_host_public_ip" {
  value = module.podman_host.public_ips[0]
}

output "compose_host_public_ip" {
  value = module.compose_host.public_ips[0]
}

output "swarm_nodes_public_ips" {
  value = module.swarm_nodes.public_ips
}

output "swarm_nodes_private_ips" {
  value = module.swarm_nodes.private_ips
}

output "ssh_command_docker" {
  value = "ssh -i ${var.project_name}-${var.environment}-key.pem ubuntu@${module.docker_host.public_ips[0]}"
}

output "ssh_command_podman" {
  value = "ssh -i ${var.project_name}-${var.environment}-key.pem ubuntu@${module.podman_host.public_ips[0]}"
}

output "ssh_command_compose" {
  value = "ssh -i ${var.project_name}-${var.environment}-key.pem ubuntu@${module.compose_host.public_ips[0]}"
}

output "test_docker_host" {
  value = "curl -i http://${module.docker_host.public_ips[0]}:8080/"
}

output "test_podman_host" {
  value = "curl -i http://${module.podman_host.public_ips[0]}:8080/"
}

output "test_compose_host" {
  value = "curl -i http://${module.compose_host.public_ips[0]}:8080/"
}

output "test_swarm_nodes" {
  value = [for ip in module.swarm_nodes.public_ips : "curl -i http://${ip}/"]
}

output "k3s_public_ip" {
  value = module.k3s_server.public_ips[0]
}

output "ssh_command_k3s" {
  description = "SSH to k3s server directly"
  value       = "ssh -i ${var.project_name}-${var.environment}-key.pem ubuntu@${module.k3s_server.public_ips[0]}"
}

output "get_kubeconfig" {
  description = "Command to get kubeconfig from k3s server"
  value       = "scp -i ${var.project_name}-${var.environment}-key.pem ubuntu@${module.k3s_server.public_ips[0]}:/etc/rancher/k3s/k3s.yaml k3s.yaml"
}

output "k3s_local_access" {
  description = "configure kubectl locally to access k3s server"
  value       = "export KUBECONFIG=./k3s.yaml && sed -i '' 's/127.0.0.1/${module.k3s_server.public_ips[0]}/g' k3s.yaml && kubectl get nodes"
}

