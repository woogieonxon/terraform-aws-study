# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# Internet Gateway route table
resource "aws_route_table" "Public_Route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "Public_rt"
  }
}

# Internet Gateway route table association
resource "aws_route_table_association" "Public_subnet_1" {
  subnet_id      = aws_subnet.Public_subnet_a.id
  route_table_id = aws_route_table.Public_Route_table.id
}

resource "aws_route_table_association" "Public_subnet_2" {
  subnet_id      = aws_subnet.Public_subnet_c.id
  route_table_id = aws_route_table.Public_Route_table.id
}
