variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "AZ for the public subnet."
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block of the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "Ubuntu AMI ID (never launched here, any plausible value works)."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "admin_user" {
  description = "Non-root user created on the instance (passwordless sudo)."
  type        = string
  default     = "deploy"
}

variable "ssh_public_key" {
  description = "Optional public key added to the admin user's authorized_keys."
  type        = string
  default     = ""
}

variable "ssh_cidr" {
  description = "The one CIDR allowed to SSH to the instance, e.g. 203.0.113.10/32. No default on purpose."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "ssh_cidr must be a valid CIDR and must not be 0.0.0.0/0."
  }
}
