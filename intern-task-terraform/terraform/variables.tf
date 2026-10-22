variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix for all resources."
  type        = string
  default     = "intern-task-app"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (must sit inside vpc_cidr)."
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "AZ for the subnet. Null lets AWS choose."
  type        = string
  default     = null
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS (amd64) AMI. The cloud-init script assumes apt + systemd."
  type        = string
  default     = "ami-0e86e20dae9224db8" # Ubuntu 24.04 LTS, us-east-1
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_allowed_cidr" {
  description = "The single CIDR allowed to SSH in, e.g. \"203.0.113.10/32\". No default: there is no sane one."
  type        = string

  # A prefix floor, not just a 0.0.0.0/0 check: 0.0.0.0/1 is half the internet.
  # /24 still fits a small office range; a single host should be /32.
  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr)) && can(regex("/(2[4-9]|3[0-2])$", var.ssh_allowed_cidr))
    error_message = "ssh_allowed_cidr must be a valid IPv4 CIDR with a prefix of /24 or narrower (e.g. your IP as /32)."
  }
}

variable "admin_user" {
  description = "Non-root user created on the instance with passwordless sudo."
  type        = string
  default     = "deploy"
}

variable "ssh_public_key" {
  description = "Public key authorized for admin_user. Null creates the user without SSH access."
  type        = string
  default     = null
}
