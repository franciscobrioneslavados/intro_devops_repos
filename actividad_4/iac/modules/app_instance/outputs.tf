output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "EC2 instance public IP (if in public subnet)"
  value       = aws_instance.app.public_ip
}

output "instance_private_ip" {
  description = "EC2 instance private IP"
  value       = aws_instance.app.private_ip
}

output "instance_public_dns" {
  description = "EC2 instance public DNS"
  value       = aws_instance.app.public_dns
}

output "instance_private_dns" {
  description = "EC2 instance private DNS"
  value       = aws_instance.app.private_dns
}

output "ebs_data_volume_id" {
  description = "EBS data volume ID"
  value       = aws_ebs_volume.app_data.id
}
