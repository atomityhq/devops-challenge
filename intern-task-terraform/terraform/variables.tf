variable "ami_id" {
  description = "AMI Ubuntu amd64 pour le plan de test en us-east-1"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_name" {
  description = "Nom de l'instance EC2"
  type        = string
  default     = "intern-task-app"
}