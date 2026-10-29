provider "aws" {
  region = var.region

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  default_tags {
    tags = {
      Project   = "intern-task"
      ManagedBy = "terraform"
    }
  }
}