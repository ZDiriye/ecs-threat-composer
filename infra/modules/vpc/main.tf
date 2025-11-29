//creates the vpc
resource "aws_vpc" "ecs" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ecs-vpc"
  }
}

//creates the igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecs.id

  tags = {
    Name = "igw"
  }
}

//creates a subnet in the eu-west-2a AZ
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.ecs.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public1"
  }
}

//creates a subnet in the eu-west-2b AZ
resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.ecs.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "public2"
  }
}

//creates route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ecs.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

//associates the igw route table with the subnets which becomes a public subnets by routing
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

//associates the igw route table with the subnets which becomes a public subnets by routing
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}