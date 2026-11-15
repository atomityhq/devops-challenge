# Provider mocking is local only: no AWS resources or credentials are used.
mock_provider "aws" {}

variables {
  ssh_cidr = "203.0.113.10/32"
}

run "initial" {
  command = apply
  assert {
    condition     = aws_instance.app.user_data_replace_on_change == false
    error_message = "Bootstrap updates must not automatically replace the instance."
  }
  assert {
    condition     = output.app_port == 5000
    error_message = "The output port must match the Dockerfile."
  }
}

run "unrelated_tag_change" {
  command = plan
  variables {
    name = "intern-task-app-renamed"
  }
  assert {
    condition     = aws_instance.app.id == run.initial.instance_id
    error_message = "Changing a Name tag must preserve the instance identity."
  }
  assert {
    condition     = aws_instance.app.user_data == local.user_data
    error_message = "Bootstrap data must remain stable after unrelated changes."
  }
}

run "reject_world_open_ssh" {
  command = plan
  variables {
    ssh_cidr = "0.0.0.0/0"
  }
  expect_failures = [var.ssh_cidr]
}
