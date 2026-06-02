output "security_group_id" {
  description = "The ID of the security group created for the ECS service."
  value       = aws_security_group.this.id
}

output "service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "service_arn" {
  description = "The ARN of the ECS service."
  value       = aws_ecs_service.this.arn
}

output "task_definition_arn" {
  description = "The ARN of the task definition."
  value       = aws_ecs_task_definition.this.arn
}
