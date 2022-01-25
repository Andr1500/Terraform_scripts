provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {}

terraform {
  backend "s3" {
    bucket = "a1500-terraform-remote-state"  #bucket for terraform state file
    key    = "dev/network/terraform.tfstate" #remote path of the file
    region = "eu-central-1"                  #region where the bucket is created
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name  = "${var.env}-vpc"
    Owner = "a1500"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name  = "${var.env}-igw"
    Owner = "a1500"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name  = "${var.env}-public-${count.index + 1}"
    Owner = "a1500"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name  = "${var.env}-route-public-subnets"
    Owner = "a1500"
  }
}

resource "aws_route_table_association" "public_toutes" { #attaching route table to all created elements
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}
