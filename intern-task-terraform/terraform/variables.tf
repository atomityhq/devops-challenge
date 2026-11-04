variable "aws_region" {
  type        = string
  description = "AWS region."
  default     = "us-east-1"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names and Name tags."
  default     = "intern-task"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet."
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  type        = string
  description = "AZ for the subnet."
  default     = "us-east-1a"
}

variable "ami_id" {
  type        = string
  description = "Ubuntu AMI placeholder for plan/validate."
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "app_port" {
  type        = number
  description = "Port the app listens on. Must match Task 1 Dockerfile."
  default     = 8080
  validation {
    condition     = var.app_port >= 1024 && var.app_port <= 65535
    error_message = "app_port must be between 1024 and 65535 (non-root container execution)."
  }
}

variable "admin_user" {
  type        = string
  description = "Name of the non-root login user created on the instance."
  default     = "deploy"
}

variable "ssh_public_key" {
  type        = string
  description = "Public key for admin_user."
  default     = ""
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "The one CIDR allowed to SSH in, e.g., 203.0.113.10/32."
  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && !contains(["0.0.0.0/0", "::/0"], var.ssh_allowed_cidr)
    error_message = "ssh_allowed_cidr must be a valid CIDR and cannot be open to the public internet (0.0.0.0/0 or ::/0)."
  }
}