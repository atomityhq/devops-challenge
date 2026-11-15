variable "region" {
  description = "AWS region; the default AMI is an illustrative Ubuntu 24.04 image for us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS amd64 AMI. Verify availability in the selected region before any real deployment."
  type        = string
  default     = "ami-04b4f1a9cf54c11d0"
}

variable "ssh_cidr" {
  description = "Specific trusted IPv4 CIDR allowed by the security group for SSH. The host firewall intentionally blocks SSH per the challenge."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && try(tonumber(split("/", var.ssh_cidr)[1]) >= 24, false)
    error_message = "Provide a specific IPv4 CIDR with prefix /24 through /32, e.g. 203.0.113.10/32; world-open SSH is forbidden."
  }
}

variable "instance_type" {
  description = "EC2 instance size."
  type        = string
  default     = "t3.micro"
}

variable "name" {
  description = "Name tag; changing it must not replace the instance."
  type        = string
  default     = "intern-task-app"
}
