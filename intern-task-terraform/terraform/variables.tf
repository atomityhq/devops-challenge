variable "region" {
  description = "Region the module plans against. Nothing is ever created."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI for the instance. Default is an Ubuntu 22.04 LTS x86_64 image in us-east-1. Any plausible ami-* value works here because no instance is ever launched."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type. t3.micro is enough for one container and is free-tier eligible."
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Port the application listens on. This is not a free choice: it must match ENV PORT in intern-task-app/Dockerfile, and it is the same value used for the security group rule and the ufw rule."
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "app_port must be a valid TCP port between 1 and 65535."
  }
}

variable "ssh_cidr" {
  description = "CIDR allowed to reach SSH on port 22. No default on purpose: there is no defensible default for \"my IP\", and a default of 0.0.0.0/0 would silently be the wrong answer."
  type        = string

  validation {
    condition = (
      can(cidrhost(var.ssh_cidr, 0)) &&
      var.ssh_cidr != "0.0.0.0/0" &&
      var.ssh_cidr != "::/0"
    )
    error_message = "ssh_cidr must be a valid CIDR block, and must not be 0.0.0.0/0 or ::/0."
  }
}
