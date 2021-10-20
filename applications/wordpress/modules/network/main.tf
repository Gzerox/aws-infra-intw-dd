locals {
  # Utility - Easily manage the naming convention for network components
  name_suffix="${var.aws_resource_suffix}"
}

resource "aws_vpc" "main" {
  cidr_block       = var.aws_vpc_cidr_block

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

##################################
#         Public Subnets
##################################
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

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rt-${local.name_suffix}-${each.value.availability_zone}-pub"
  }
}
# Associate RT <-> SN
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.value.availability_zone].id
}

##################################
#         Private Subnets
##################################
resource "aws_subnet" "private" {
  for_each  = var.aws_availability_zones # Lets create 1 Private Subnet for every AZ

  vpc_id     = aws_vpc.main.id
  availability_zone = each.value
  #TODO: Bad, to improve - avoid leaving "empty ip range within the cidr"
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block,4,length(aws_subnet.public)+index(tolist(var.aws_availability_zones),each.value))

    map_public_ip_on_launch = false
  tags = {
    Name = "${local.name_suffix}-${each.value}-prv"
  }
}
# Let make sure we can reach the NAT gateway from private-routing-table
resource "aws_route_table" "private" {
  for_each  = aws_subnet.private # Lets create 1 RT for every Private Subnet
  vpc_id = aws_vpc.main.id

  #route = []
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[each.value.availability_zone].id
  }

  tags = {
    Name = "rt-${local.name_suffix}-${each.value.availability_zone}-prv"
  }
}
# Associate RT <-> SN
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.value.availability_zone].id
}

# EIP For the Nat Gateway
resource "aws_eip" "gw" {
  for_each  = var.aws_availability_zones # Lets create 1 EIP for every AZ
  vpc      = true

  tags = {
    Name = "eip-ngw-${local.name_suffix}-${each.value}"
  }
}

# Resource required whenever we want to go out in the internet from private subnet
resource "aws_nat_gateway" "main" {
  for_each  = aws_subnet.public

  allocation_id = aws_eip.gw[each.value.availability_zone].id
  subnet_id = each.value.id

  tags = {
    Name = "ngw-${local.name_suffix}-${each.value.availability_zone}"
  }

  # From Terraform Documentation:
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}