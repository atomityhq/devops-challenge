variable "ami_id" {
  description = "Ubuntu AMI for the EC2 instance"
  type        = string
  default     = "ami-0866a3c8686eaeeba"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Trusted IPv4 CIDR allowed to access SSH"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "Enter a valid, restricted IPv4 CIDR. SSH cannot be open to everyone."
  }
}
