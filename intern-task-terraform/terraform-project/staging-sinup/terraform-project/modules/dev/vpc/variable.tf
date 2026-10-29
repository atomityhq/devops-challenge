variable "vpc_name" {
  description = "Name of the VPC"
  type        = string

  validation {
    condition     = length(var.vpc_name) > 0
    error_message = "vpc_name must not be empty."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  default = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used by the VPC"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones are required."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))
    ])

    error_message = "All public subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))
    ])

    error_message = "All private subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "tags" {
  description = "Common tags applied to all VPC resources"
  type        = map(string)

  default = {}
}
/*variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_cidrs) == length(var.availability_zones)
    )

    error_message = "Number of public subnet CIDRs must match number of Availability Zones."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)

  validation {
    condition = (
      length(var.private_subnet_cidrs) == length(var.availability_zones)
    )

    error_message = "Number of private subnet CIDRs must match number of Availability Zones."
  }
} */
variable "flow_log_retention_days" {
  description = "CloudWatch retention period for VPC Flow Logs"
  type        = number

  default = 30

  validation {
    condition     = var.flow_log_retention_days > 0
    error_message = "Flow log retention must be greater than 0."
  }
}
variable "aws_region" {
  description = "AWS region"
  type        = string
}

/*variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)

  validation {
    condition = (
      length(var.database_subnet_cidrs) ==
      length(var.availability_zones)
    )

    error_message = "Database subnet CIDRs must match the number of Availability Zones."
  }

  validation {
    condition = alltrue([
      for cidr in var.database_subnet_cidrs : can(cidrnetmask(cidr))
    ])

    error_message = "All database subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}
variable "public_subnet_cidrs" {
  type = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  type = list(string)

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

variable "database_subnet_cidrs" {
  type = list(string)

  default = [
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]
} */