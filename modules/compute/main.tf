###############################################################
#  Module: compute
#  Creates: Security Groups, ALB, Target Group, Launch Template,
#           Auto Scaling Group, Scaling Policy, IAM Role
###############################################################

# ── IAM Role for EC2 (SSM + CloudWatch agent) ─────────────────
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-${var.environment}"
  role = aws_iam_role.ec2_role.name
}

# ── Security Group: ALB ────────────────────────────────────────
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${var.environment}"
  description = "Allow HTTP/HTTPS from the Internet to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-sg-${var.environment}" }
}

# ── Security Group: App (EC2) ──────────────────────────────────
resource "aws_security_group" "app_sg" {
  name        = "app-sg-${var.environment}"
  description = "Allow traffic from ALB only; egress unrestricted"
  vpc_id      = var.vpc_id

  # HTTP from ALB only
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # SSH from within VPC only (use SSM Sessions Manager instead in production)
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "app-sg-${var.environment}" }
}

# ── Application Load Balancer ──────────────────────────────────
resource "aws_lb" "main" {
  name               = "alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false   # set true for production

  tags = { Name = "alb-${var.environment}" }
}

# ── Target Group ───────────────────────────────────────────────
resource "aws_lb_target_group" "app" {
  name     = "tg-app-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }

  tags = { Name = "tg-app-${var.environment}" }
}

# ── ALB Listener (HTTP → forward) ─────────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ── User Data script ───────────────────────────────────────────
locals {
  user_data = base64encode(templatefile("${path.module}/../../user_data/install_app.sh", {
    environment = var.environment
  }))
}

# ── Launch Template ────────────────────────────────────────────
resource "aws_launch_template" "app" {
  name_prefix   = "lt-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  # Attach IAM profile
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_sg.id]
  }

  # Only attach key if provided
  key_name = var.key_name != "" ? var.key_name : null

  user_data = local.user_data

  monitoring {
    enabled = true   # detailed CloudWatch monitoring
  }

  lifecycle {
    ignore_changes  = [image_id]
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "server-${var.environment}"
      Environment = var.environment
    }
  }
}

# ── Auto Scaling Group ─────────────────────────────────────────
resource "aws_autoscaling_group" "app" {
  name                      = "asg-${var.environment}"
  desired_capacity          = var.asg_desired_capacity
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "asg-instance-${var.environment}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Target Tracking Scaling Policy (CPU) ──────────────────────
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "cpu-target-tracking-${var.environment}"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}
