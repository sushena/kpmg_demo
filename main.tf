terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.45.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = var.aws_profile
  region = var.region
}

#Lookup for Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC
resource "aws_vpc" "kpmg-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name        = "${var.project}-${var.env}-vpc"
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}

# Creating Subnets

# Create Web Public Subnet
resource "aws_subnet" "fe-subnet-1" {
  vpc_id                  = aws_vpc.kpmg-vpc.id
  cidr_block              = var.vpc_public_subnets[0]
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${var.env}-fe-subnet-01"
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}

resource "aws_subnet" "fe-subnet-2" {
  vpc_id                  = aws_vpc.kpmg-vpc.id
  cidr_block              = var.vpc_public_subnets[1]
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${var.env}-fe-subnet-02"
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}


# Create Application Subnet (Middleware)
resource "aws_subnet" "app-subnet-1" {
  vpc_id                  = aws_vpc.kpmg-vpc.id
  cidr_block              = var.vpc_private_subnets[0]
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
     Name        = "${var.project}-${var.env}-app-subnet01"
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}

resource "aws_subnet" "app-subnet-2" {
  vpc_id                  = aws_vpc.kpmg-vpc.id
  cidr_block              = var.vpc_private_subnets[1]
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
     Name       = "${var.project}-${var.env}-app-subnet02"
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}

# Create Database Subnet
resource "aws_subnet" "db-subnet-1" {
  vpc_id            = aws_vpc.kpmg-vpc.id
  cidr_block              = var.vpc_database_subnets[0]
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
     Name       = "${var.project}-${var.env}-db-subnet01"
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}

resource "aws_subnet" "db-subnet-2" {
  vpc_id            = aws_vpc.kpmg-vpc.id
  cidr_block              = var.vpc_database_subnets[1]
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
     Name       = "${var.project}-${var.env}-db-subnet02"
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}

# Creating Gateways and Route Tables

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kpmg-vpc.id

  tags = {
    Name       = "${var.project}-${var.env}-igw"
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}

# Create FE layer route table
resource "aws_route_table" "fe-rt" {
  vpc_id = aws_vpc.kpmg-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "FE-RT"
  }
}

# Create FE Subnet association with Web route table
resource "aws_route_table_association" "fe01" {
  subnet_id      = aws_subnet.fe-subnet-1.id
  route_table_id = aws_route_table.fe-rt.id
}

resource "aws_route_table_association" "fe02" {
  subnet_id      = aws_subnet.fe-subnet-2.id
  route_table_id = aws_route_table.fe-rt.id
}

#Create Nat Gateway
resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.fe-subnet-1.id
  tags = {
    Name       = "${var.project}-${var.env}-natgw"
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}

# Create APP and DB layer route table
resource "aws_route_table" "app-rt" {
  vpc_id = aws_vpc.kpmg-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "APP-RT"
  }
}

# Create APP and DB Subnet association with APP route table
resource "aws_route_table_association" "app01" {
  subnet_id      = aws_subnet.app-subnet-1.id
  route_table_id = aws_route_table.app-rt.id
}

resource "aws_route_table_association" "app02" {
  subnet_id      = aws_subnet.app-subnet-2.id
  route_table_id = aws_route_table.app-rt.id
}

resource "aws_route_table_association" "db01" {
  subnet_id      = aws_subnet.db-subnet-1.id
  route_table_id = aws_route_table.app-rt.id
}

resource "aws_route_table_association" "db02" {
  subnet_id      = aws_subnet.db-subnet-2.id
  route_table_id = aws_route_table.app-rt.id
}

# Output Network Values
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.kpmg-vpc.id
}

output "cidr_block" {
  description = "vpc cidr"
  value       = aws_vpc.kpmg-vpc.cidr_block
}

output "public_subnets_1" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.fe-subnet-1.id
}

output "public_subnets_2" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.fe-subnet-2.id
}

output "private_subnets_1" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.app-subnet-1.id
}

output "private_subnets_2" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.app-subnet-2.id
}

output "db_subnets_1" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.db-subnet-1.id
}

output "db_subnets_2" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.db-subnet-2.id
}
