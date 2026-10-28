variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "ssh_allowed_cidr" {
  description = "Single CIDR allowed to SSH to the instance, e.g. \"203.0.113.10/32\"."
  type        = string
  # No default on purpose: there's no sane default for "my IP".

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "ssh_allowed_cidr must be a valid CIDR and must not be 0.0.0.0/0."
  }
}

variable "ami_id" {
  description = "Ubuntu 24.04 AMI. AMI IDs are region-specific; this default is for us-east-1."
  type        = string
  default     = "ami-0fb0b230890ccd1e6"
}

variable "instance_type" {
  description = "EC2 instance type for the web server."
  type        = string
  default     = "t3.micro"
}