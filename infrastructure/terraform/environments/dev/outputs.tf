output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.db_endpoint
}

output "db_name" {
  description = "ShopSphere database name"
  value       = module.rds.db_name
}

output "db_port" {
  description = "RDS PostgreSQL port"
  value       = module.rds.db_port
}

output "db_instance_id" {
  description = "RDS DB instance identifier"
  value       = module.rds.db_instance_id
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = module.rds.security_group_id
}
