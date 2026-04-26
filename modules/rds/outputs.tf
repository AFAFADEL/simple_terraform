output "rds_endpoint" {
  description = "Connection endpoint for the RDS instance (host:port)"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_address" {
  description = "Hostname of the RDS instance (without port)"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  description = "Port the RDS MySQL instance listens on"
  value       = aws_db_instance.mysql.port
}

output "rds_sg_id" {
  description = "Security Group ID of the RDS instance — referenced by the compute module"
  value       = aws_security_group.rds_sg.id
}

output "rds_identifier" {
  description = "Identifier (name) of the RDS instance"
  value       = aws_db_instance.mysql.identifier
}

output "db_subnet_group_name" {
  description = "Name of the DB Subnet Group used by the RDS instance"
  value       = aws_db_subnet_group.main.name
}
