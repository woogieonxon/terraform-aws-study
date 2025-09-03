#Subnet settings

resource "aws_subnet" "Public_subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name                     = "Public_subnet_a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "Public_subnet_c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name                     = "Public_subnet_c"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "Private_was_subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name                              = "Private_was_subnet_a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "Private_was_subnet_c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.40.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name                              = "Private_was_subnet_c"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "Private_db_subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.50.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name                              = "Private_db_subnet_a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "Private_db_subnet_c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.60.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name                              = "Private_db_subnet_c"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
