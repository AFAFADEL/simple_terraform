output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (one per AZ) — used by the ALB"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (one per AZ) — used by ASG and RDS"
  value       = aws_subnet.private[*].id
}

output "igw_id" {
  description = "ID of the Internet Gateway attached to the VPC"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (allows private instances to reach the Internet)"
  value       = aws_nat_gateway.main.id
}

output "nat_eip" {
  description = "Elastic IP address assigned to the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}
