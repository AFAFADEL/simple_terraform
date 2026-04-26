# ── Development environment ───────────────────────────────────
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
public_state         = true

instance_type        = "t2.micro"
environment          = "development"
region               = "us-east-1"

# Auto Scaling (leaner for dev)
asg_min_size         = 1
asg_max_size         = 2
asg_desired_capacity = 1
cpu_target_value     = 70

# RDS (disabled in dev to save cost)
enable_rds           = false
db_instance_class    = "db.t3.micro"
db_name              = "appdb"
db_username          = "admin"
db_password          = "dev_password_123"

# Monitoring
alert_email          = "ssg745488@gmail.com.com"
key_name             = ""
