#############################################
################################3##########
#############################################
resource "aws_vpc" "aws_evareg" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = var.instance_tenancy
  tags = {
    Name = "aws"
  }
}
###############################################
###############Subnet creation Public #########
###############################################
resource "aws_subnet" "aws_evareg_public_subnet" {
  vpc_id            = aws_vpc.aws_evareg.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zone
  tags = {
    Name = "aws-public-subnet"
  }
}
resource "aws_subnet" "aws_evareg_public_subnet_1" {
  vpc_id            = aws_vpc.aws_evareg.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = var.availability_zone
  tags = {
    Name = "aws-public-subnet_1"
  }
}
#################################################
############Subnet creation Private #############
#################################################

resource "aws_subnet" "aws_evareg_private_subnet" {
  vpc_id            = aws_vpc.aws_evareg.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zone

}
resource "aws_subnet" "aws_evareg_private_subnet_1" {
  vpc_id            = aws_vpc.aws_evareg.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zone

}
resource "aws_subnet" "aws_evareg_private_subnet_2" {
  vpc_id            = aws_vpc.aws_evareg.id
  cidr_block        = var.private_subnet_cidrs[2]
  availability_zone = var.availability_zone

}
#################################################
############internet Gateway####################
##################################################

resource "aws_internet_gateway" "aws_evareg_internet_gateway" {
  vpc_id = aws_vpc.aws_evareg.id
  tags = {
    Name = "aws-internet-gateway"
  }
}
#################################################
##############Route Table  Assocation ###########
#################################################
resource "aws_route_table" "aws_evareg_public_route_table" {
  vpc_id = aws_vpc.aws_evareg.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_evareg_internet_gateway.id
  }
}

resource "aws_route_table" "aws_evareg_private_route_table" {
  vpc_id = aws_vpc.aws_evareg.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_evareg_internet_gateway.id
  }


}

resource "aws_route_table_association" "aws_evareg_private_route_table_association" {
  subnet_id      = aws_subnet.aws_evareg_private_subnet.id
  route_table_id = aws_route_table.aws_evareg_private_route_table.id


}

resource "aws_route_table_association" "aws_evareg_public_route_table_association" {
  subnet_id      = aws_subnet.aws_evareg_public_subnet.id
  route_table_id = aws_route_table.aws_evareg_public_route_table.id
}


########################################################
########################################################
########################################################