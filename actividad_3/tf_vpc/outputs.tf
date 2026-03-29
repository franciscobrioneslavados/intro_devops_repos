output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "web_tier_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "application_tier_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "database_tier_subnet_ids" {
  description = "List of IDs of database/extra private subnets"
  value       = aws_subnet.database_subnet[*].id
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.this[*].public_ip
}

output "vpc_all_tags" {
  description = "Tags applied to all VPC resources"
  value       = aws_vpc.this.tags_all
}
