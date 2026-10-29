resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-subnet-group"
    }
  )
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database access from application instances"
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = [var.application_security_group_id]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )
}

resource "aws_db_instance" "this" {
  identifier = var.name

  engine         = var.engine
  instance_class = var.instance_class
  port           = var.port

  db_name  = var.database_name
  username = var.master_username

  manage_master_user_password = true

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_id

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  publicly_accessible = false
  multi_az            = var.multi_az

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final-snapshot"

  performance_insights_enabled = var.performance_insights_enabled

  copy_tags_to_snapshot = true

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}