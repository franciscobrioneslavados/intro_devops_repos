output "frontend_security_group_id" {
  description = "Security group ID for frontend"
  value       = aws_security_group.frontend.id
}

output "backend_security_group_id" {
  description = "Security group ID for backend"
  value       = aws_security_group.backend.id
}

output "database_security_group_id" {
  description = "Security group ID for database"
  value       = aws_security_group.database.id
}
