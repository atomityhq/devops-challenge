
# Terraform Implementation

## Overview

This Terraform configuration describes the AWS infrastructure needed to run the Python application from the first task.

## Infrastructure

- VPC with a public subnet
- Internet Gateway and public route table
- EC2 instance using Amazon Linux
- Security group with restricted SSH access
- Application access on port 5000

## Application Setup

The EC2 instance uses a user-data script to:

- Create a non-root Linux user with sudo access
- Install Docker
- Build the application from the original Dockerfile
- Run the container using a systemd service
- Configure the host firewall

The systemd service is enabled to start automatically after a reboot.

## Terraform Configuration

I used `ignore_changes` for `user_data` because cloud-init runs during the first boot. This avoids replacing an existing instance just because the bootstrap script changes.

## CI Fixes

The original GitHub Actions workflow was missing the correct working directory and Terraform initialization.

I updated the workflow to run formatting checks, initialization, and validation from the Terraform directory.

I also updated the workflow triggers to include changes to the workflow file itself.

## Local Testing

The following checks passed:

- terraform fmt -check
- terraform init
- terraform validate
- terraform plan with dummy AWS credentials

The plan showed 10 resources to create, with no changes or deletions.

No AWS resources were deployed. The bootstrap script has not been tested on a running EC2 instance.
