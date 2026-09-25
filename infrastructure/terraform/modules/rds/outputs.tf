output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.this.address
}

output "db_name" {
  description = "ShopSphere database name"
  value       = aws_db_instance.this.db_name
}

output "db_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.this.port
}

output "db_instance_id" {
  description = "RDS DB instance identifier"
  value       = aws_db_instance.this.id
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.this.id
}
