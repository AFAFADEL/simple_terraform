output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer — use this to access the app"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "Full ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the ALB (used in CloudWatch metric dimensions)"
  value       = aws_lb.main.arn_suffix
}

output "tg_arn_suffix" {
  description = "ARN suffix of the Target Group (used in CloudWatch metric dimensions)"
  value       = aws_lb_target_group.app.arn_suffix
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "app_sg_id" {
  description = "Security Group ID attached to EC2 instances (used by RDS module to allow DB access)"
  value       = aws_security_group.app_sg.id
}

output "alb_sg_id" {
  description = "Security Group ID attached to the ALB"
  value       = aws_security_group.alb_sg.id
}

output "launch_template_id" {
  description = "ID of the EC2 Launch Template"
  value       = aws_launch_template.app.id
}

output "iam_role_name" {
  description = "Name of the IAM Role attached to EC2 instances"
  value       = aws_iam_role.ec2_role.name
}
