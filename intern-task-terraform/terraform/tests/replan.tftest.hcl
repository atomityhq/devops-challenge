mock_provider "aws" {
  mock_resource "aws_instance" {
    defaults = {
      id        = "i-0123456789abcdef0"
      public_ip = "198.51.100.10"
    }
  }
}

variables {
  ssh_cidr = "203.0.113.10/32"
}

run "initial_state" {
  command = apply

  assert {
    condition     = aws_instance.app.id == "i-0123456789abcdef0"
    error_message = "The mocked instance must exist before checking a later plan."
  }
}

run "unrelated_tag_change" {
  command = plan

  variables {
    tags = {
      Environment = "replan-check"
    }
  }

  assert {
    condition     = aws_instance.app.tags["Environment"] == "replan-check"
    error_message = "The later plan must include the unrelated tag change."
  }

  assert {
    condition     = aws_instance.app.id == "i-0123456789abcdef0"
    error_message = "The later plan must preserve the existing mocked instance identity."
  }
}

run "reject_open_ssh" {
  command = plan

  variables {
    ssh_cidr = "0.0.0.0/0"
  }

  expect_failures = [var.ssh_cidr]
}