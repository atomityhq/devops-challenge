variable "name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "ami_id" {
  description = "AMI used by the launch template"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  description = "Private subnet IDs for the ASG"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs assigned to instances"
  type        = list(string)
}

variable "target_group_arns" {
  description = "ALB target group ARNs attached to the ASG"
  type        = list(string)
  default     = []
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 4
}

variable "health_check_grace_period" {
  description = "Time before checking a new instance's health"
  type        = number
  default     = 300
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "iam_instance_profile_name" {
  description = "Optional IAM instance profile name"
  type        = string
  default     = null
}

variable "user_data" {
  description = "EC2 user-data script"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags assigned to resources"
  type        = map(string)
  default     = {}
}