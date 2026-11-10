provider "aws" {
  region = var.aws_region

  # These settings allow local planning with fake credentials.
  # No real AWS account is required for this challenge.
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}
