output "alb_dns_name" {
  description = "Public ALB DNS name."
  value       = aws_lb.this.dns_name
}

output "application_url" {
  description = "Application URL."
  value       = "http://${aws_lb.this.dns_name}"
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.this.name
}

output "ecr_repository_urls" {
  description = "ECR repositories for the application images."
  value       = { for name, repo in aws_ecr_repository.app : name => repo.repository_url }
}

output "service_discovery_namespace" {
  description = "Private DNS namespace used by ECS services."
  value       = aws_service_discovery_private_dns_namespace.this.name
}
