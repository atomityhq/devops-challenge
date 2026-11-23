mock_provider "aws" {}

variables {
  ssh_cidr = "203.0.113.10/32"
}

run "create_baseline" {
  command = apply
}

run "change_ssh_network" {
  command = plan
  variables {
    ssh_cidr = "203.0.113.11/32"
  }

  assert {
    condition     = length(aws_instance.app.id) > 0 && aws_instance.app.public_ip == run.create_baseline.public_ip
    error_message = "Changing the SSH rule must preserve the existing computed public IP."
  }
}

run "reject_world_open_ssh" {
  command = plan
  variables {
    ssh_cidr = "0.0.0.0/0"
  }
  expect_failures = [var.ssh_cidr]
}
