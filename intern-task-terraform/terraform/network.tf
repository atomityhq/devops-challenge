# Create an isolated virtual network for the application.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create a public subnet within the VPC.
# Automatically assign public IPs to launched instances.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Attach an Internet Gateway to enable internet connectivity.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Route internet-bound traffic through the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Associate the public subnet with the internet route table.
# Without this association, the subnet would not use our public route.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
