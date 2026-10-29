# Example variable
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}


variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string

  default = "evareg-project"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string

  default = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

variable "database_subnet_cidrs" {
  type = list(string)

  default = [
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]
}


##############################
############# EC2 ############
##############################

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
  default     = "ami-08eb58865930c986c"
}


variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "root_volume_size" {
  type    = number
  default = 50
}

variable "data_volume_size" {
  type    = number
  default = 100
}

variable "data_device_name" {
  type    = string
  default = "/dev/sdf"
}


variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to EC2"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "https_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "enable_detailed_monitoring" {
  type    = bool
  default = false
}

variable "backup_schedule" {
  type    = string
  default = "cron(0 2 * * ? *)"
}

variable "backup_retention_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}