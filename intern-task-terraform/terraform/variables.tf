variable "region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "eu-central-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0faab6bdbac9486fb"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "IPv4 CIDR block for the subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_allowed_cidr" {
  description = "Single IPv4 CIDR block allowed to access the instance via SSH (port 22). Open access (0.0.0.0/0) is prohibited."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr)) && var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "Must be a valid IPv4 CIDR block (e.g., 203.0.113.10/32) and cannot be 0.0.0.0/0."
  }
}

variable "admin_username" {
  description = "Username for the administrative user created via cloud-init"
  type        = string
  default     = "deploy"
}

variable "ssh_public_key" {
  description = "SSH public key for accessing"
  type        = string
  default     = ""
}
