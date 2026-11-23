variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 x86_64 AMI. Supply a matching image when changing regions."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_cidr" {
  description = "IPv4 network allowed to reach the SSH port at the security group."
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && can(regex("/([1-9]|[12][0-9]|3[0-2])$", var.ssh_cidr))
    error_message = "Supply an IPv4 CIDR with a prefix from /1 through /32."
  }
}
