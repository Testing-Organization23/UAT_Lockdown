terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

# Public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name}-public-${element(var.azs, count.index)}",
    "kubernetes.io/role/elb" = "1"
  })
}

# Private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(var.tags, {
    Name = "${var.name}-private-${element(var.azs, count.index)}",
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# NAT Gateways and EIPs
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs)
  domain = "vpc"
  tags = merge(var.tags, { Name = "${var.name}-nat-eip-${count.index}" })
}

resource "aws_nat_gateway" "this" {
  count = length(var.public_subnet_cidrs)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  allocation_id = element(aws_eip.nat[*].id, count.index)

  tags = merge(var.tags, { Name = "${var.name}-nat-${count.index}" })
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.this[*].id, count.index)
  }

  tags = merge(var.tags, { Name = "${var.name}-private-rt-${count.index}" })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = element(aws_route_table.private[*].id, count.index)
}
