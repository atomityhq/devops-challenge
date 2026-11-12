
variable "ssh_cidr" {
  description = "CIDR allowed to access the instance over SSH"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "Provide a valid SSH CIDR. Open access is not allowed."
  }
}

variable "ami_id" {
  description = "AMI used for the EC2 instance"
  type        = string
  default     = "ami-063d43db0594b521b"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
