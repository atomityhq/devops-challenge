variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Availability zone for the subnet, set explicitly so planning never calls AWS."
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  description = "Address range for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Address range for the public subnet, inside vpc_cidr."
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance size."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu AMI. Never launched here, so any plausible Ubuntu AMI ID works; a data source lookup would call AWS and break offline planning."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "ssh_cidr" {
  description = "The single CIDR allowed to SSH in, e.g. 203.0.113.10/32. No default: there is no safe default for \"my IP\"."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && try(tonumber(split("/", var.ssh_cidr)[1]) > 0, false)
    error_message = "ssh_cidr must be a valid IPv4 CIDR such as 203.0.113.10/32, and must not be 0.0.0.0/0."
  }
}

variable "admin_user" {
  description = "Non-root user created on the instance, with passwordless sudo."
  type        = string
  default     = "deploy"
}

variable "admin_ssh_public_key" {
  description = "Optional SSH public key for admin_user. Empty means none is installed."
  type        = string
  default     = ""
}