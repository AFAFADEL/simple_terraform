variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g. 10.0.0.0/16)"
  type        = string
}

variable "public_subnets_cidrs" {
  description = "List of CIDR blocks for public subnets — one per Availability Zone"
  type        = list(string)
}

variable "private_subnets_cidrs" {
  description = "List of CIDR blocks for private subnets — one per Availability Zone"
  type        = list(string)
}

variable "public_state" {
  description = "Whether instances in public subnets receive a public IP automatically"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of Availability Zone names to spread subnets across"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (dev, production) — used in resource Name tags"
  type        = string
}
