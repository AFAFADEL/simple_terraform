variable "environment" {
  description = "Environment name (dev, production) — used in alarm and topic names"
  type        = string
}

variable "region" {
  description = "AWS region where resources are deployed (required by CloudWatch Dashboard widgets)"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group to monitor"
  type        = string
}

variable "alb_arn" {
  description = "Full ARN of the Application Load Balancer"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB — used as a CloudWatch metric dimension"
  type        = string
}

variable "tg_arn_suffix" {
  description = "ARN suffix of the Target Group — used as a CloudWatch metric dimension"
  type        = string
}

variable "alert_email" {
  description = "Email address that will receive SNS alert notifications"
  type        = string
}
