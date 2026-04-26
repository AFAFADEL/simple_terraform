###############################################################
#  Root main.tf — wires all modules together
###############################################################

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "scalable-web-app"
      ManagedBy   = "terraform"
    }
  }
}

# ── AMI data source (Ubuntu 22.04) ────────────────────────────
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── Availability zones ─────────────────────────────────────────
data "aws_availability_zones" "available" {
  state = "available"
}

# ── Networking module ──────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  vpc_cidr              = var.vpc_cidr
  public_subnets_cidrs  = var.public_subnets_cidrs
  private_subnets_cidrs = var.private_subnets_cidrs
  public_state          = var.public_state
  availability_zones    = data.aws_availability_zones.available.names
  environment           = var.environment
}

# ── Compute module (ALB + ASG + EC2) ──────────────────────────
module "compute" {
  source = "./modules/compute"

  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  public_subnet_ids    = module.networking.public_subnet_ids
  private_subnet_ids   = module.networking.private_subnet_ids
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  key_name             = var.key_name
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity
  cpu_target_value     = var.cpu_target_value
  enable_rds           = var.enable_rds
  rds_sg_id            = var.enable_rds ? module.rds[0].rds_sg_id : ""
}

# ── RDS module (optional) ──────────────────────────────────────
module "rds" {
  count  = var.enable_rds ? 1 : 0
  source = "./modules/rds"

  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  app_sg_id         = module.compute.app_sg_id
  db_instance_class = var.db_instance_class
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}

# ── Monitoring module (CloudWatch + SNS) ──────────────────────
module "monitoring" {
  source = "./modules/monitoring"

  environment    = var.environment
  region         = var.region
  asg_name       = module.compute.asg_name
  alb_arn        = module.compute.alb_arn
  alb_arn_suffix = module.compute.alb_arn_suffix
  tg_arn_suffix  = module.compute.tg_arn_suffix
  alert_email    = var.alert_email
}
