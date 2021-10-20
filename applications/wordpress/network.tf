
locals {
  # Utility - Easily manage the naming convention for network components
  name_suffix="${var.project_name}-${var.aws_region}"
}

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block

  tags = {
    Name = "vpc-${local.name_suffix}"
  }
}

# Provide access to internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${local.name_suffix}"
  }
}

# TODO: This can be improved in many different ways
# ISSUE: The 'netnum' params need to be increased 
resource "aws_subnet" "public" {
  for_each  = var.aws_availability_zones # Lets create 1 Public Subnet for every AZ

  vpc_id     = aws_vpc.main.id

  availability_zone = each.value

  cidr_block = cidrsubnet(aws_vpc.main.cidr_block,4,index(tolist(var.aws_availability_zones),each.value))

    map_public_ip_on_launch = true
  tags = {
    Name = "${local.name_suffix}-${each.value}-pub"
  }
}
# Make sure we can get out on internet with this route table
resource "aws_route_table" "public" {
  for_each  = aws_subnet.public # Lets create 1 RT for every public subnet
  vpc_id = aws_vpc.main.id

  route = []

    tags = {
      Name = "rt-${local.name_suffix}-${each.value.availability_zone}-pub"
    }
}
resource "aws_route" "public" {
  for_each=aws_route_table.public

  route_table_id             = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id      = aws_internet_gateway.main.id
}

resource "aws_subnet" "private" {
  for_each  = var.aws_availability_zones # Lets create 1 Private Subnet for every AZ

  vpc_id     = aws_vpc.main.id
  availability_zone = each.value
  #cidr_block = cidrsubnet(aws_vpc.main.cidr_block,4,2)
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block,4,length(aws_subnet.public)+index(tolist(var.aws_availability_zones),each.value))

    map_public_ip_on_launch = false
  tags = {
    Name = "${local.name_suffix}-${each.value}-prv"
  }
}
# Let make sure we can reach the NAT gateway from private-routing-table
# Make sure we can get out on internet with this route table
resource "aws_route_table" "private" {
  for_each  = aws_subnet.private # Lets create 1 RT for every Private Subnet
  vpc_id = aws_vpc.main.id
}
resource "aws_route" "private" {
  count= length(aws_route_table.private)

  route_table_id              = element(aws_route_table.private,count.index).id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id      = element(aws_nat_gateway.main,count.index).id
}


# EIP For the Nat Gateway
resource "aws_eip" "gw" {
  count  = length(var.aws_availability_zones) # Lets create 1 EIP for every AZ
  vpc      = true
}

# Resource required whenever we want to go out in the internet from private subnet
#TODO: We need to create NatGateway<->EIP for every az.
resource "aws_nat_gateway" "main" {
  for_each  = aws_subnet.public

  allocation_id = element(aws_eip.gw,0).id
  subnet_id = each.value.id

  tags = {
    Name = "ngw-${local.name_suffix}-1a"
  }

  # From Terraform Documentation:
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

