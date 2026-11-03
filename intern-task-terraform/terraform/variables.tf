variable "aws_region" {
  description = "AWS region used for the infrastructure plan."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Planning-only placeholder AMI ID. Bootstrap will assume Ubuntu 24.04 on x86_64."
  type        = string
  default     = "ami-0123456789abcdef0"
}

variable "instance_type" {
  description = "EC2 instance size."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "IPv4 CIDR permitted to access SSH in the security group."
  type        = string

  validation {
    condition     = try(cidrnetmask(var.ssh_cidr) != "0.0.0.0", false)
    error_message = "Provide a valid IPv4 CIDR. Unrestricted /0 access is not allowed."
  }
}