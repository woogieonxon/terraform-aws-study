# Nat Gateway

resource "aws_eip" "NAT" {
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "Private_NAT" {
  subnet_id     = aws_subnet.Public_subnet_a.id
  allocation_id = aws_eip.NAT.id
  #secondary_allocation_ids       = [aws_eip.secondary.id]
  #secondary_private_ip_addresses = ["10.0.1.5"]

  tags = {
    Name = "NAT"
  }
}

resource "aws_eip" "NAT2" {
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_nat_gateway" "Private_NAT2" {
  subnet_id     = aws_subnet.Public_subnet_c.id
  allocation_id = aws_eip.NAT2.id
  #secondary_allocation_ids       = [aws_eip.secondary.id]
  #secondary_private_ip_addresses = ["10.0.1.5"]

  tags = {
    Name = "NAT2"
  }
}

# Nat Gateway Routing table

resource "aws_route_table" "Private_Route_table_a" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Private_NAT.id
  }

  tags = {
    Name = "Private_rt_a"
  }
}

resource "aws_route_table" "Private_Route_table_c" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Private_NAT2.id
  }

  tags = {
    Name = "Private_rt_c"
  }
}

# Nat Gateway Routing table association 
resource "aws_route_table_association" "Private_subnet_1" {
  subnet_id      = aws_subnet.Private_was_subnet_a.id
  route_table_id = aws_route_table.Private_Route_table_a.id
}

resource "aws_route_table_association" "Private_subnet_2" {
  subnet_id      = aws_subnet.Private_was_subnet_c.id
  route_table_id = aws_route_table.Private_Route_table_c.id
}

resource "aws_route_table_association" "Private_subnet_3" {
  subnet_id      = aws_subnet.Private_was_subnet_a.id
  route_table_id = aws_route_table.Private_Route_table_a.id
}

resource "aws_route_table_association" "Private_subnet_4" {
  subnet_id      = aws_subnet.Private_was_subnet_c.id
  route_table_id = aws_route_table.Private_Route_table_c.id
}

resource "aws_route_table_association" "Private_subnet_5" {
  subnet_id      = aws_subnet.Private_db_subnet_a.id
  route_table_id = aws_route_table.Private_Route_table_a.id
}

resource "aws_route_table_association" "Private_subnet_6" {
  subnet_id      = aws_subnet.Private_db_subnet_c.id
  route_table_id = aws_route_table.Private_Route_table_c.id
}
