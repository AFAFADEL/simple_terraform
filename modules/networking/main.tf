###############################################################
#  Module: networking
#  Creates: VPC, IGW, public & private subnets (Multi-AZ),
#           route tables, NAT Gateway
###############################################################

# ── VPC ───────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${var.environment}"
  }
}

# ── Internet Gateway ───────────────────────────────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${var.environment}"
  }
}

# ── Public Subnets (one per AZ) ────────────────────────────────
resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.public_state

  tags = {
    Name = "subnet-public-${count.index + 1}-${var.environment}"
    Tier = "public"
  }
}

# ── Private Subnets (one per AZ) ──────────────────────────────
resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "subnet-private-${count.index + 1}-${var.environment}"
    Tier = "private"
  }
}

# ── Elastic IP for NAT Gateway ─────────────────────────────────
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "eip-nat-${var.environment}"
  }
}

# ── NAT Gateway (in first public subnet) ──────────────────────
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "nat-${var.environment}"
  }

  depends_on = [aws_internet_gateway.main]
}

# ── Public Route Table ─────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rt-public-${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ── Private Route Table (via NAT) ─────────────────────────────
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "rt-private-${var.environment}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
