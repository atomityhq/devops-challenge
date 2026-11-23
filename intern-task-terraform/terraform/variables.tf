variable "ssh_cidr" {
  description = "Trusted IPv4 CIDR allowed by the security group's SSH rule."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && !endswith(var.ssh_cidr, "/0")
    error_message = "Provide a trusted IPv4 CIDR narrower than /0."
  }
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS amd64 AMI in us-east-1 for this plan-only exercise."
  type        = string
  default     = "ami-0866a3c8686eaeeba"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance."
  type        = string
  default     = "intern-task-app"
}
