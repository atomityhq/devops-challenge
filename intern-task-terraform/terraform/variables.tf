variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix applied to every resource."
  type        = string
  default     = "intern-task"
}

variable "ssh_cidr" {
  description = <<-EOT
    The one CIDR allowed to SSH in (e.g. "203.0.113.7/32"). Deliberately has
    no default: there is no sane default for "my IP", and a permissive one
    would silently open SSH to the world.
  EOT
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr))
    error_message = "ssh_cidr must be a valid IPv4 CIDR, e.g. 203.0.113.7/32."
  }

  validation {
    condition     = !can(cidrnetmask(var.ssh_cidr)) || split("/", var.ssh_cidr)[1] != "0"
    error_message = "ssh_cidr must not be a /0. Restrict SSH to your own address range."
  }
}

variable "ssh_public_key" {
  description = "Public key installed for the admin user. No default: it has to be yours."
  type        = string
}

variable "admin_username" {
  description = "Non-root user created on the instance, with passwordless sudo."
  type        = string
  default     = "deploy"

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]{0,31}$", var.admin_username)) && var.admin_username != "root"
    error_message = "admin_username must be a valid, non-root Linux username."
  }
}

variable "ami_id" {
  description = <<-EOT
    AMI to launch. Must be Ubuntu (user_data relies on apt, ufw and
    systemd). Default is an Ubuntu 24.04 LTS amd64 image in us-east-1;
    it is never actually launched here, so any plausible ID works.
  EOT
  type        = string
  default     = "ami-0e86e20dae9224db8"

  validation {
    condition     = can(regex("^ami-[0-9a-f]{8,17}$", var.ami_id))
    error_message = "ami_id must look like an AMI ID (ami-xxxxxxxx)."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
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

variable "availability_zone" {
  description = <<-EOT
    AZ for the subnet. Optional: null lets AWS pick. Not looked up via a
    data source because that would call AWS during plan.
  EOT
  type        = string
  default     = null
}
