provider "aws" {
  region                      = var.aws_region
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "instance" {
  name        = "${var.name}-instance"
  description = "SSH from the configured CIDR and the application port from the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from the configured CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Application traffic"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-security-group"
  }
}

resource "aws_instance" "app" {
  # AMI (Amazon Machine Image) used to launch the EC2 instance.
  # The AMI ID is provided through a Terraform variable.
  ami = var.ami_id

  # EC2 instance size, such as t2.micro or t3.small.
  instance_type = var.instance_type

  # Launch the EC2 instance inside the public subnet we created.
  subnet_id = aws_subnet.public.id

  # Attach the security group that controls inbound and outbound traffic.
  vpc_security_group_ids = [aws_security_group.instance.id]

  # Assign a public IPv4 address so the instance can be accessed externally.
  associate_public_ip_address = true

  # Generate the EC2 startup script using our user_data.sh.tftpl template.
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {

    # Pass the application port to the startup script.
    app_port = var.app_port

    # Read the actual Python application source code and encode it in Base64.
    # This allows us to transfer the file through EC2 user_data.
    app_source_b64 = base64encode(file("${path.module}/../../intern-task-app/app/app.py"))

    # Read the application's Dockerfile and encode it in Base64.
    dockerfile_b64 = base64encode(file("${path.module}/../../intern-task-app/Dockerfile"))

    # Pass the Linux username that will be created on the EC2 instance.
    linux_user = var.linux_user

    # Pass the allowed SSH source CIDR to configure restricted SSH access.
    ssh_cidr = var.ssh_cidr
  })

  # Prevent Terraform from replacing the EC2 instance just because user_data
  # changes. Important: EC2 user_data normally runs during initial boot;
  # changing it does not automatically rerun the script on an existing host.
  user_data_replace_on_change = false

  # Add a Name tag to make the EC2 instance identifiable in AWS.
  tags = {
    Name = "${var.name}-app"
  }
}

