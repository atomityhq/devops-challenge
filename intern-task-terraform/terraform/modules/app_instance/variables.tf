variable "name" {
  description = "Name prefix for resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC the security group belongs to."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet to launch the instance into."
  type        = string
}

variable "ami_id" {
  description = "AMI for the instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "app_port" {
  description = "TCP port the app listens on."
  type        = number
}

variable "ssh_allowed_cidr" {
  description = "The single CIDR allowed to SSH in."
  type        = string
}

variable "user_data" {
  description = "cloud-init user_data, applied once at first boot."
  type        = string
}
