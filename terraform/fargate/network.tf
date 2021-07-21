resource "aws_vpc" "terraform-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name        = format("%s-vpc-%s", var.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.region}a"

  tags = {
    Name        = format("%s-public-%s", var.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = "dev"
  }
}
resource "aws_subnet" "public-b" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.region}b"

  tags = {
    Name        = format("%s-public-%s", var.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = "dev"
  }
}
resource "aws_subnet" "private-a" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.region}a"

  tags = {
    Name        = format("%s-private-%s", var.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = "dev"
  }
}
resource "aws_subnet" "private-b" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.region}b"

  tags = {
    Name        = format("%s-private-%s", var.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name        = format("%s-internet-gateway-%s", var.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = "dev"
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table
resource "aws_default_route_table" "default-rt" {
  default_route_table_id = aws_vpc.terraform-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name        = format("%s-default-rt-%s", var.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = "dev"
  }
}
