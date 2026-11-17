mock_provider "aws" {}

variables {
  ssh_cidr = "203.0.113.10/32"
}

run "create_instance" {
  command = apply

  assert {
    condition     = strcontains(aws_instance.app.user_data, "ufw allow 8080/tcp")
    error_message = "The first apply should render the startup script with port 8080."
  }
}

run "change_user_data_on_existing_instance" {
  command = plan

  variables {
    app_port = 9090
  }

  assert {
    condition     = strcontains(aws_instance.app.user_data, "ufw allow 8080/tcp")
    error_message = "A new app_port changed user_data on an existing instance. ignore_changes should keep the old script."
  }
}