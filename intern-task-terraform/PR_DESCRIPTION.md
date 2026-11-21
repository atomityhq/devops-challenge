# Add Terraform EC2 application infrastructure

## Pipeline fixes

- Restricted pull request and push path filters to changes that affect this Terraform task or its workflow.
- Added the workflow file itself to the path filters so workflow-only fixes are validated.
- Run formatting against `intern-task-terraform/terraform` rather than the wrong repository root.
- Added `terraform init -backend=false` before `terraform validate`, since validation needs initialized provider dependencies.
- Run both initialization and validation in `intern-task-terraform/terraform`.

## Terraform changes

- Added a VPC, public subnet, internet gateway, public route table, and route-table association.
- Added a security group allowing SSH only from the required `ssh_cidr` variable and the app on port 8080 from the internet.
- Added one EC2 instance with provider settings that permit local planning with fake credentials.
- Embedded the real `intern-task-app` Dockerfile and Python source in `user_data`, build the image, and run it through a Docker-backed systemd service.
- Configured UFW to allow only SSH from `ssh_cidr` and app traffic on port 8080.
- Added public-IP and app-port outputs.

## User data replacement

This configuration uses `user_data_replace_on_change = false` and ignores `user_data` in the instance lifecycle. Both are intentional: AWS user data is a first-boot bootstrap mechanism and should not trigger EC2 replacement when an unrelated setting changes. `ignore_changes` prevents drift in rendered user data from being treated as an infrastructure update.
