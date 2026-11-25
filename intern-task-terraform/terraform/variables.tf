variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix applied to provisioned resources."
  type        = string
  default     = "intern-task-app"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "public_subnet_cidr must be a valid IPv4 CIDR block."
  }
}

variable "ssh_allowed_cidr" {
  description = "Single CIDR block permitted to reach SSH (port 22) on the instance, e.g. 203.0.113.10/32."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "ssh_allowed_cidr must be a valid IPv4 CIDR block and cannot be 0.0.0.0/0."
  }
}

variable "app_port" {
  description = "Port that intern-task-app listens on (must match intern-task-app/Dockerfile)."
  type        = number
  default     = 5000

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "app_port must be a valid TCP port between 1 and 65535."
  }
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI ID for the target region."
  type        = string
  default     = "ami-0e2c8caa4b6378d8c"
}

variable "instance_type" {
  description = "EC2 instance type for running the containerized app."
  type        = string
  default     = "t3.micro"
}

variable "admin_user" {
  description = "Non-root Linux user created on the instance with passwordless sudo."
  type        = string
  default     = "appuser"
}
