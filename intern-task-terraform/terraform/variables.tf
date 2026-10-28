variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for resource names and Name tags."
  type        = string
  default     = "intern-task-app"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet. Must sit inside vpc_cidr."
  type        = string
  default     = "10.0.1.0/24"
}
variable "ssh_cidr" {
  description = "The single IPv4 CIDR allowed to reach SSH, for example your own IP as x.x.x.x/32. No default on purpose."
  type        = string

  validation {
    condition = (
      can(cidrhost(var.ssh_cidr, 0)) &&
      can(regex("^[0-9.]+/[0-9]{1,2}$", var.ssh_cidr)) &&
      var.ssh_cidr != "0.0.0.0/0"
    )
    error_message = "ssh_cidr must be a valid IPv4 CIDR such as 203.0.113.10/32, and must not be 0.0.0.0/0."
  }
}
variable "ami_id" {
  description = "Ubuntu 24.04 LTS (amd64) AMI for the region; the bootstrap script needs apt, systemd and ufw. The default is a placeholder: the current ID is published in SSM at /aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id."
  type        = string
  default     = "ami-0a1b2c3d4e5f67890"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}