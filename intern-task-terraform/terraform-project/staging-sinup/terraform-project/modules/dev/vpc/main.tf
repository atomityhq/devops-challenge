resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

# ---------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

# ---------------------------------------------------------
# Public Subnets
# ---------------------------------------------------------

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  cidr_block = var.public_subnet_cidrs[count.index]

  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-${var.availability_zones[count.index]}"
      Tier = "Public"
    }
  )
}

# ---------------------------------------------------------
# Private Subnets
# ---------------------------------------------------------

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  cidr_block = var.private_subnet_cidrs[count.index]

  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-${var.availability_zones[count.index]}"
      Tier = "Private"
    }
  )
}

# ---------------------------------------------------------
# Elastic IPs for NAT Gateways
# One EIP per AZ
# ---------------------------------------------------------

resource "aws_eip" "nat" {
  count = length(var.availability_zones)

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-eip-${var.availability_zones[count.index]}"
    }
  )
}

# ---------------------------------------------------------
# NAT Gateway
# One NAT Gateway per AZ
# ---------------------------------------------------------

resource "aws_nat_gateway" "this" {
  count = length(var.availability_zones)

  allocation_id = aws_eip.nat[count.index].id

  subnet_id = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-${var.availability_zones[count.index]}"
    }
  )

  depends_on = [
    aws_internet_gateway.this
  ]
}

# ---------------------------------------------------------
# Public Route Table
# ---------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-rt"
    }
  )
}

# Public Internet Route

resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.this.id
}

# ---------------------------------------------------------
# Public Route Table Associations
# ---------------------------------------------------------

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------
# Private Route Tables
# One route table per AZ
# ---------------------------------------------------------

resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-rt-${var.availability_zones[count.index]}"
    }
  )
}

# ---------------------------------------------------------
# Private Internet Route through NAT Gateway
# ---------------------------------------------------------

resource "aws_route" "private_nat" {
  count = length(var.availability_zones)

  route_table_id = aws_route_table.private[count.index].id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.this[count.index].id
}

# ---------------------------------------------------------
# Private Route Table Associations
# ---------------------------------------------------------

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id = aws_subnet.private[count.index].id

  route_table_id = aws_route_table.private[count.index].id
}


# ---------------------------------------------------------
# CloudWatch Log Group
# ---------------------------------------------------------

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.vpc_name}/flow-logs"
  retention_in_days = var.flow_log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-flow-logs"
    }
  )
}

# ---------------------------------------------------------
# IAM Role for VPC Flow Logs
# ---------------------------------------------------------

resource "aws_iam_role" "flow_logs" {
  name = "${var.vpc_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# ---------------------------------------------------------
# IAM Policy for Flow Logs
# ---------------------------------------------------------

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.vpc_name}-flow-logs-policy"

  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
      }
    ]
  })
}

# ---------------------------------------------------------
# VPC Flow Log
# ---------------------------------------------------------

resource "aws_flow_log" "this" {
  vpc_id = aws_vpc.this.id

  traffic_type = "ALL"

  iam_role_arn = aws_iam_role.flow_logs.arn

  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-flow-log"
    }
  )
}

# ---------------------------------------------------------
# S3 Gateway VPC Endpoint
# ---------------------------------------------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}.s3"

  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private[*].id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-s3-endpoint"
    }
  )
}
# ---------------------------------------------------------
# Database Subnets
# ---------------------------------------------------------

/*resource "aws_subnet" "database" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  cidr_block = var.database_subnet_cidrs[count.index]

  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-db-${var.availability_zones[count.index]}"
      Tier = "Database"
    }
  )
} */
# ---------------------------------------------------------
# DynamoDB Gateway VPC Endpoint
# ---------------------------------------------------------

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}.dynamodb"

  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private[*].id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-dynamodb-endpoint"
    }
  )
}
# ---------------------------------------------------------
# Database Route Tables
# ---------------------------------------------------------

/*resource "aws_route_table" "database" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-db-rt-${var.availability_zones[count.index]}"
    }
  )
} */
# ---------------------------------------------------------
# Database Subnets
# ---------------------------------------------------------

/*resource "aws_subnet" "database" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  cidr_block = var.database_subnet_cidrs[count.index]

  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-db-${var.availability_zones[count.index]}"
      Tier = "Database"
    }
  )
} */

# ---------------------------------------------------------
# Database Route Associations
# ---------------------------------------------------------

/*resource "aws_route_table_association" "database" {
  count = length(var.availability_zones)

  subnet_id = aws_subnet.database[count.index].id

  route_table_id = aws_route_table.database[count.index].id
} */
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-nacl"
    }
  )
}

resource "aws_network_acl_rule" "private_inbound_vpc" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 100

  egress = false

  protocol = "-1"

  rule_action = "allow"

  cidr_block = var.vpc_cidr
}

resource "aws_network_acl_rule" "private_outbound_vpc" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 100

  egress = true

  protocol = "-1"

  rule_action = "allow"

  cidr_block = var.vpc_cidr
}