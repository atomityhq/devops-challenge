locals {
  name = "intern-task-app"

  tags = {
    Name    = local.name
    Project = local.name
  }

  # The real Dockerfile and the real app source from the other task, read from
  # disk at plan time and base64-encoded so YAML indentation cannot corrupt
  # them. No copy is kept here, so the two tasks cannot drift apart.
  #
  # base64 costs ~33% in size and buys the indentation safety; the whole
  # rendering is ~4.7 KB, comfortably inside AWS's 16 KB user_data limit.
  user_data = templatefile("${path.module}/user_data.yaml.tftpl", {
    app_port       = var.app_port
    ssh_cidr       = var.ssh_cidr
    dockerfile_b64 = base64encode(file("${path.module}/../../intern-task-app/Dockerfile"))
    app_py_b64     = base64encode(file("${path.module}/../../intern-task-app/app/app.py"))
  })
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.tags, { Name = "${local.name}-vpc" })
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"

  tags = merge(local.tags, { Name = "${local.name}-public" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, { Name = "${local.name}-igw" })
}

# A CIDR block does not make a subnet public. The subnet is public because a
# route table with a default route to the internet gateway is attached to it -
# all three resources below are required, and dropping the association is the
# usual way this looks correct and is not.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.tags, { Name = "${local.name}-public" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Exactly two ingress paths: SSH from one operator CIDR, and the application
# port from anywhere. Inline rules rather than separate rule resources so the
# complete ingress policy is readable in one place.
resource "aws_security_group" "app" {
  name        = "${local.name}-app"
  description = "SSH from var.ssh_cidr and the application port from the internet, nothing else"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH from the operator CIDR only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Application port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound, needed to install packages and pull the base image"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.name}-app" })
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true
  user_data                   = local.user_data

  lifecycle {
    # cloud-init runs user_data once, at first boot. AWS cannot push changed
    # user data into an instance that is already running, so a diff on this
    # attribute is one that can never take effect while the instance lives.
    # Because this module embeds the app source, any app edit changes
    # user_data - so this is load-bearing, not defensive.
    #
    # Trade-off: an intentional bootstrap change will not reach a running
    # instance either. Applying one means replacing the instance deliberately
    # (terraform apply -replace=aws_instance.this).
    ignore_changes = [user_data]
  }

  tags = local.tags
}
