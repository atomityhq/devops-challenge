provider "aws" {
  region = var.aws_region

  # Plumbing so `terraform plan` can run against fake credentials without ever
  # calling AWS (nothing is deployed in this challenge).
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  default_tags {
    tags = {
      Project   = var.name
      ManagedBy = "terraform"
    }
  }
}
