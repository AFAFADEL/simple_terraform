variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (one per AZ)"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (one per AZ)"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "public_state" {
  type        = bool
  description = "Whether public subnets auto-assign public IPs"
  default     = true
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the web app"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, production)"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

# ── Auto Scaling ──────────────────────────────────────────────
variable "asg_min_size" {
  type        = number
  description = "Minimum number of EC2 instances in the ASG"
  default     = 2
}

variable "asg_max_size" {
  type        = number
  description = "Maximum number of EC2 instances in the ASG"
  default     = 6
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired number of EC2 instances in the ASG"
  default     = 2
}

variable "cpu_target_value" {
  type        = number
  description = "Target CPU utilisation (%) for the scaling policy"
  default     = 60
}

# ── RDS (optional) ───────────────────────────────────────────
variable "enable_rds" {
  type        = bool
  description = "Whether to create the RDS MySQL instance"
  default     = false
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "db_name" {
  type        = string
  description = "Name of the MySQL database"
  default     = "appdb"
}

variable "db_username" {
  type        = string
  description = "Master username for RDS"
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Master password for RDS"
  sensitive   = true
  default     = ""
}

# ── Monitoring & Alerts ───────────────────────────────────────
variable "alert_email" {
  type        = string
  description = "Email address for CloudWatch / SNS alerts"
  default     = "ops@example.com"
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 Key Pair (leave empty to skip)"
  default     = ""
}
