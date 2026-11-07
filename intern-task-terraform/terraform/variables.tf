variable "ssh_cidr" {
  description = "IPv4 CIDR allowed to access SSH."
  type        = string
  nullable    = false

  validation {
    condition = (
      can(cidrnetmask(var.ssh_cidr)) &&
      !contains(
        ["0.0.0.0/0", "0.0.0.0/1", "128.0.0.0/1"],
        var.ssh_cidr
      )
    )
    error_message = "Provide a valid, restricted IPv4 CIDR for SSH."
  }
}

variable "ami_id" {
  description = "Ubuntu 24.04 x86_64 AMI ID in us-east-1; replace before a real deployment."
  type        = string
  default     = "ami-0123456789abcdef0"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Prefix used to name project resources."
  type        = string
  default     = "intern-task"
}
