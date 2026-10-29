variable "aws_region" {
  description = "AWS region for the planned infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Plausible Ubuntu 22.04 AMI ID for us-east-1; no instance is launched."
  type        = string
  default     = "ami-0e2c8caa4b6378d8c"
}

variable "instance_type" {
  description = "EC2 instance size."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Trusted source CIDR allowed to connect over SSH, e.g. 203.0.113.10/32."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr))
    error_message = "ssh_cidr must be a valid IPv4 CIDR, such as 203.0.113.10/32."
  }
}