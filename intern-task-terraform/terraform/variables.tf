variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "intern-task"
}

variable "ami_id" {
  description = "Placeholder Ubuntu AMI (never launched)"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH in (e.g. x.x.x.x/32). No default on purpose."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "ssh_cidr must be a valid CIDR and must not be 0.0.0.0/0."
  }
}

variable "ssh_public_key" {
  description = "Public key for the admin user. No default on purpose."
  type        = string
}

variable "admin_user" {
  type    = string
  default = "deploy"
}

variable "app_port" {
  description = "Port the app listens on; must match PORT in intern-task-app's Dockerfile (8080)."
  type        = number
  default     = 8080
}