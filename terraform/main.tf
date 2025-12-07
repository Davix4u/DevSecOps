terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  
  
  tags = {
    Name        = "Interswitch-VPC"
    Environment = "Production"
    Project     = "Interswitch-CICD"
    ManagedBy   = "Terraform"
    Region      = "us-east-1"  # Explicit region tag
  }
}

# --- Subnets in us-east-1 availability zones ---
resource "aws_subnet" "public_switch_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"  # Explicit AZ

  tags = {
    Name        = "public-switch-1"
    Type        = "public"
    Environment = "Production"
    Zone        = "us-east-1a"
    Region      = "us-east-1"
  }
}

resource "aws_subnet" "public_switch_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"  # Explicit AZ

  tags = {
    Name        = "public-switch-2"
    Type        = "public"
    Environment = "Production"
    Zone        = "us-east-1b"
    Region      = "us-east-1"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "interswitch_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "Interswitch-IGW"
    Environment = "Production"
    Region      = "us-east-1"
  }
}

# --- Route Table ---
resource "aws_route_table" "public_switch_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.interswitch_igw.id
  }
}

# --- Route Table Associations ---
resource "aws_route_table_association" "interswitch_public_switch_1_route" {
  subnet_id      = aws_subnet.public_switch_1.id
  route_table_id = aws_route_table.public_switch_rt.id
}

resource "aws_route_table_association" "interswitch_public_switch_2_route" {
  subnet_id      = aws_subnet.public_switch_2.id
  route_table_id = aws_route_table.public_switch_rt.id
}