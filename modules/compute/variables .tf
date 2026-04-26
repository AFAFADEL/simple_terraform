variable "environment" {
  description = "Environment name (dev, production)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB (one per AZ)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EC2 instances (one per AZ)"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances (Ubuntu 22.04)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t2.micro, t3.medium)"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 Key Pair for SSH access (leave empty to disable)"
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "cpu_target_value" {
  description = "Target CPU utilisation (%) for the Target Tracking scaling policy"
  type        = number
  default     = 60
}

variable "enable_rds" {
  description = "Whether an RDS instance is enabled (used to conditionally add RDS SG to EC2)"
  type        = bool
  default     = false
}

variable "rds_sg_id" {
  description = "Security Group ID of the RDS instance (required when enable_rds = true)"
  type        = string
  default     = ""
}
