variable "name" {
  description = "RDS instance identifier"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the RDS security group"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the RDS subnet group"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "RDS requires at least two private subnets."
  }
}

variable "application_security_group_id" {
  description = "Security group permitted to connect to RDS"
  type        = string
}

variable "engine" {
  description = "RDS database engine"
  type        = string
  default     = "mysql"
}

variable "port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "database_name" {
  description = "Initial database name"
  type        = string
  default     = "evareg"
}

variable "master_username" {
  description = "Master database username"
  type        = string
  default     = "dbadmin"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial storage size in GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum autoscaled storage size in GiB"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Daily backup window in UTC"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Weekly maintenance window in UTC"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "apply_immediately" {
  description = "Apply modifications immediately"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Prevent accidental RDS deletion"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot when deleting RDS"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable RDS Performance Insights"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Optional KMS key ARN for storage encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags assigned to RDS resources"
  type        = map(string)
  default     = {}
}