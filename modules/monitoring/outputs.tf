output "sns_topic_arn" {
  description = "ARN of the SNS topic used for alert notifications"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS alerts topic"
  value       = aws_sns_topic.alerts.name
}

output "high_cpu_alarm_arn" {
  description = "ARN of the High CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu.arn
}

output "unhealthy_hosts_alarm_arn" {
  description = "ARN of the Unhealthy Hosts CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.unhealthy_hosts.arn
}

output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5xx errors CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
