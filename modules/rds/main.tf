###############################################################
#  Module: rds
#  Creates: DB Subnet Group, RDS Security Group, MySQL Multi-AZ
###############################################################

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg-${var.environment}"
  description = "Allow MySQL from app security group only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from app layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "rds-sg-${var.environment}" }
}

resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = { Name = "rds-subnet-group-${var.environment}" }
}

resource "aws_db_instance" "mysql" {
  identifier             = "mysql-${var.environment}"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az               = true
  publicly_accessible    = false
  storage_type           = "gp3"
  allocated_storage      = 20
  max_allocated_storage  = 100

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  deletion_protection = false   # set true for production
  skip_final_snapshot = true    # set false for production

  tags = { Name = "rds-${var.environment}" }
}
