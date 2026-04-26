variable "environment" {
  description = "Environment name (dev, production) — used in resource names and tags"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the RDS instance will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB Subnet Group (minimum 2 for Multi-AZ)"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security Group ID of the application (EC2) layer — granted MySQL access to RDS"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class (e.g. db.t3.micro, db.t3.small)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the initial MySQL database to create"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for the RDS instance (min 8 characters)"
  type        = string
  sensitive   = true
}
