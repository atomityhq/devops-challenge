# intern-task-terraform

This module provisions one public EC2 instance that runs the real
[`intern-task-app`](../intern-task-app/) container. It does not use
provisioners or Kubernetes.

## What is included

- A VPC, public subnet, internet gateway, public route table, and association.
- A security group allowing SSH only from `ssh_allowed_cidr` and application
  traffic on port `app_port` from the internet.
- An EC2 instance whose user data embeds the Phase 1 Dockerfile and
  `app/app.py`, rebuilds the image, and runs it under a systemd service.
- UFW configured to deny incoming traffic by default, allow the application
  port, and allow SSH only from the configured CIDR.

The default application port is `5000`. `ssh_allowed_cidr` is intentionally
required because there is no safe universal default for administrative access.

## User-data lifecycle choice

The instance sets `user_data_replace_on_change = false`. Cloud-init consumes
user data during first boot and cannot reliably update an already-running
instance, while the AWS provider otherwise treats a user-data change as a
replacement trigger. Keeping the instance in place avoids accidental
replacement during unrelated Terraform changes. A deliberate instance refresh
or configuration-management run is required when bootstrap behavior itself
needs to change.

## Local validation

Run Terraform commands from the root module directory:

```bash
cd terraform
export AWS_ACCESS_KEY_ID=fake
export AWS_SECRET_ACCESS_KEY=fake
export AWS_DEFAULT_REGION=ap-southeast-1

terraform fmt -recursive
terraform init -backend=false
terraform validate
terraform plan -var='ssh_allowed_cidr=203.0.113.10/32'
```

The plan is configuration-only and must not be followed by `terraform apply`
for this challenge. The expected plan contains seven resources to create,
including the VPC path, security group, and EC2 instance, with outputs for the
instance public IP and application port.

The GitHub Actions workflow runs format checking, backendless initialization,
and validation from `intern-task-terraform/terraform/` for pull requests and
pushes to `main` that affect this module or the workflow itself. It also
supports manual dispatch.
