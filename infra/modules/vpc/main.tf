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

//creates a subnet in the eu-west-2a and eu-west-2b AZs
resource "aws_subnet" "public" {
  count      = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.ecs.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "public${count.index + 1}"
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

//associates the igw route table with the subnets
resource "aws_route_table_association" "public" {
  count      = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}