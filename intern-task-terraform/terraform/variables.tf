variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (must be inside vpc_cidr)."
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH in, e.g. your IP as x.x.x.x/32. No default on purpose."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "ssh_allowed_cidr must be a valid CIDR and must not be 0.0.0.0/0."
  }
}

variable "ami_id" {
  description = "Ubuntu AMI ID. Verify region and architecture before any real deployment."
  type        = string
  default     = "ami-0e86e20dae9224db8"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional existing EC2 key pair for the image's default user."
  type        = string
  default     = null
}

variable "admin_user" {
  description = "Name of the non-root admin user created by cloud-init."
  type        = string
  default     = "deploy"
}

variable "admin_ssh_public_key" {
  description = "Optional SSH public key for admin_user."
  type        = string
  default     = null
}