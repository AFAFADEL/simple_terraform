# ── Production environment ────────────────────────────────────
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
public_state         = true

instance_type        = "t3.medium"
environment          = "production"
region               = "us-east-1"

# Auto Scaling
asg_min_size         = 2
asg_max_size         = 6
asg_desired_capacity = 2
cpu_target_value     = 60

# RDS
enable_rds           = true
db_instance_class    = "db.t3.micro"
db_name              = "appdb"
db_username          = "admin"
db_password          = "CHANGE_ME_strong_password_123!"   # replace or use TF_VAR_db_password env var

# Monitoring
alert_email          = "ops@example.com"
key_name             = ""   # e.g. "my-key-pair"
