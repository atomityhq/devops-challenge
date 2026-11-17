variable "aws_region" {
  description = "AWS region for the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID. The example default is for this validation-only challenge."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type for the application."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "IPv4 CIDR permitted to access SSH. Access from everywhere is forbidden."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.ssh_cidr)) &&
      try(tonumber(split("/", var.ssh_cidr)[1]) > 0, false)
    )
    error_message = "Provide a valid IPv4 CIDR. A /0 network is not allowed."
  }
}

variable "tags" {
  description = "Additional tags to apply to the infrastructure."
  type        = map(string)
  default     = {}
}