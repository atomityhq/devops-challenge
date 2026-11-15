mock_provider "aws" {}

variables {
  ssh_cidr = "192.0.2.10/32"
}

run "create_simulated_instance" {
  command = apply
}

run "rename_without_replacement" {
  command = plan

  variables {
    instance_name = "intern-task-app-renamed"
  }

  assert {
    condition     = aws_instance.app.tags["Name"] == "intern-task-app-renamed"
    error_message = "The plan should update the instance Name tag."
  }
}