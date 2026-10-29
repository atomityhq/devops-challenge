variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "EC2 subnet ID"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for EC2 and EBS"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 30
}

variable "data_volume_size" {
  description = "Additional EBS volume size in GB"
  type        = number
  default     = 100
}

variable "data_device_name" {
  description = "Additional EBS device name"
  type        = string
  default     = "/dev/sdf"
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH port 22"
  type        = list(string)
}

variable "http_cidr_blocks" {
  description = "CIDR blocks allowed for HTTP port 80"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "https_cidr_blocks" {
  description = "CIDR blocks allowed for HTTPS port 443"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "associate_public_ip_address" {
  description = "Associate public IP with EC2"
  type        = bool
  default     = false
}

variable "enable_detailed_monitoring" {
  description = "Enable EC2 detailed monitoring"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "EC2 user data"
  type        = string
  default     = null
}

variable "backup_schedule" {
  description = "AWS Backup daily schedule in cron format"
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}