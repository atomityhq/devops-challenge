
variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "ssh_cidr" {
  description = "IPv4 CIDR allowed to access SSH"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "Provide a valid, restricted IPv4 CIDR. SSH cannot be open to the world."
  }
}

locals {
  app_port = 5000
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI for the EC2 instance"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

