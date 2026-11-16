variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix used for resources and tags."
  type        = string
  default     = "intern-task-app"
}

variable "ami_id" {
  description = "AMI for the instance. Must be a Debian/Ubuntu image (the bootstrap uses apt and ufw). The default is a placeholder Ubuntu AMI: it is never actually launched in this challenge."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block of the public subnet (must be inside vpc_cidr)."
  type        = string
  default     = "10.0.1.0/24"
}

# No default on purpose: there is no sane default for "my IP", and a permissive
# default would silently expose SSH.
variable "ssh_cidr" {
  description = "The single CIDR allowed to SSH to the instance, e.g. \"203.0.113.7/32\"."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "ssh_cidr must be a valid CIDR block and must not be 0.0.0.0/0."
  }
}

variable "admin_username" {
  description = "Non-root user created on the instance (passwordless sudo)."
  type        = string
  default     = "deploy"
}

variable "ssh_public_key" {
  description = "Public key authorised for admin_username. Leave empty to create the user without a key."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Optional existing EC2 key pair for the AMI's default user."
  type        = string
  default     = null
}
