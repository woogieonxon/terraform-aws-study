# vi main.tf 
provider "aws" {
  region = "ap-northeast-2"
  default_tags {
    tags = {
      Name    = "VPC_Infra_${var.stage}"
      Subject = "Cloud-Programming"
    }
  }
}

variable "vpc_main_cidr" {
  description = "VPC main CIDR block"
  default     = "10.0.0.0/23"
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_main_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "VPC_Infra_${var.stage}"
  }
}

resource "aws_subnet" "Subnet-Public-A" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.my_vpc.cidr_block, 3, 0)
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet-Pulic-A"
  }
}

resource "aws_subnet" "Subnet-Public-C" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.my_vpc.cidr_block, 3, 1)
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet-Pulic-C"
  }
}

resource "aws_subnet" "Subnet-Private-Web-A" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 3, 2)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Subnet-Private-Web-A"
  }
}

resource "aws_subnet" "Subnet-Private-Web-C" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 3, 3)
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "Subnet-Private-Web-C"
  }
}

resource "aws_subnet" "Subnet-Private-DB-A" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 3, 4)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Subnet-Private-DB-A"
  }
}

resource "aws_subnet" "Subnet-Private-DB-C" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 3, 5)
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "Subnet-Private-DB-C"
  }
}

#IGW
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "RT-IGW" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "RT-IGW"
  }
}

resource "aws_route_table_association" "table-IGW-A" {
  subnet_id      = aws_subnet.Subnet-Public-A.id
  route_table_id = aws_route_table.RT-IGW.id
}

resource "aws_route_table_association" "table-IGW-C" {
  subnet_id      = aws_subnet.Subnet-Public-C.id
  route_table_id = aws_route_table.RT-IGW.id
}


#NAT
resource "aws_eip" "eip-A" {
  domain = "vpc"
  tags = {
    Name = "EIP-A"
  }
}

resource "aws_eip" "eip-C" {
  domain = "vpc"
  tags = {
    Name = "EIP-C"
  }
}

resource "aws_nat_gateway" "NAT-A" {
  allocation_id = aws_eip.eip-A.id
  subnet_id     = aws_subnet.Subnet-Public-A.id
  depends_on    = [aws_internet_gateway.IGW]

  tags = {
    Name = "NAT-A"
  }
}

resource "aws_nat_gateway" "NAT-C" {
  allocation_id = aws_eip.eip-C.id
  subnet_id     = aws_subnet.Subnet-Public-C.id
  depends_on    = [aws_internet_gateway.IGW]

  tags = {
    Name = "NAT-C"
  }
}

resource "aws_route_table" "RT-NAT-A" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT-A.id
  }

  tags = {
    Name = "RT-NAT-A"
  }
}

resource "aws_route_table" "RT-NAT-C" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT-C.id
  }

  tags = {
    Name = "RT-NAT-C"
  }
}

resource "aws_route_table_association" "table-NAT-A" {
  subnet_id      = aws_subnet.Subnet-Private-Web-A.id
  route_table_id = aws_route_table.RT-NAT-A.id
}

resource "aws_route_table_association" "table-NAT-C" {
  subnet_id      = aws_subnet.Subnet-Private-Web-C.id
  route_table_id = aws_route_table.RT-NAT-C.id
}

####S3
terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  backend "s3" {
    bucket = "woogie-s3"
    key = "dev/vpc/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    dynamodb_table = "woogie-dynamodb"
  }
}
