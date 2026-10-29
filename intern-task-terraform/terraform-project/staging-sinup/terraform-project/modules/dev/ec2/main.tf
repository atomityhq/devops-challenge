# =========================================================
# IAM ROLE
# =========================================================

resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = var.tags
}


# =========================================================
# SECURITY GROUP
# Ports: 22, 80, 443
# =========================================================

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.http_cidr_blocks
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.https_cidr_blocks
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-sg"
    }
  )
}


# =========================================================
# EC2 INSTANCE
# =========================================================

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  availability_zone = var.availability_zone

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  user_data = var.user_data

  monitoring = var.enable_detailed_monitoring

  associate_public_ip_address = var.associate_public_ip_address

  # -------------------------------------------------------
  # Root EBS Volume
  # -------------------------------------------------------

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size

    encrypted = true

    delete_on_termination = true

    tags = merge(
      var.tags,
      {
        Name   = "${var.project_name}-${var.environment}-root"
        Backup = "true"
      }
    )
  }

  # -------------------------------------------------------
  # IMDSv2
  # -------------------------------------------------------

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # -------------------------------------------------------
  # Terraform Lifecycle
  # -------------------------------------------------------

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-ec2"
      Environment = var.environment
      Backup      = "true"
    }
  )
}


# =========================================================
# ADDITIONAL EBS VOLUME
# =========================================================

resource "aws_ebs_volume" "data" {
  availability_zone = var.availability_zone

  size = var.data_volume_size
  type = "gp3"

  encrypted = true

  tags = merge(
    var.tags,
    {
      Name   = "${var.project_name}-${var.environment}-data"
      Backup = "true"
    }
  )

  lifecycle {
    prevent_destroy = false
  }
}


# =========================================================
# EBS ATTACHMENT
# =========================================================

resource "aws_volume_attachment" "data" {
  device_name = var.data_device_name

  volume_id = aws_ebs_volume.data.id

  instance_id = aws_instance.this.id

  force_detach = true
}


# =========================================================
# AWS BACKUP VAULT
# =========================================================

resource "aws_backup_vault" "this" {
  name = "${var.project_name}-${var.environment}-backup-vault"

  tags = var.tags
}


# =========================================================
# AWS BACKUP IAM ROLE
# =========================================================

resource "aws_iam_role" "backup" {
  name = "${var.project_name}-${var.environment}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "backup.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}


# =========================================================
# DAILY BACKUP PLAN
# =========================================================

resource "aws_backup_plan" "this" {
  name = "${var.project_name}-${var.environment}-daily-backup"

  rule {
    rule_name = "daily-backup"

    target_vault_name = aws_backup_vault.this.name

    # Example: 02:00 UTC every day
    schedule = var.backup_schedule

    lifecycle {
      delete_after = var.backup_retention_days
    }

    recovery_point_tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  tags = var.tags
}


# =========================================================
# BACKUP SELECTION
# =========================================================

resource "aws_backup_selection" "this" {
  name = "${var.project_name}-${var.environment}-backup-selection"

  iam_role_arn = aws_iam_role.backup.arn

  plan_id = aws_backup_plan.this.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}