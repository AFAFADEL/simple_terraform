output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer — use this URL to reach the app"
  value       = module.compute.alb_dns_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.asg_name
}

output "rds_endpoint" {
  description = "RDS endpoint (empty when enable_rds = false)"
  value       = var.enable_rds ? module.rds[0].rds_endpoint : "RDS not enabled"
}

output "sns_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = module.monitoring.sns_topic_arn
}
