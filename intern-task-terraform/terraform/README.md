# Terraform module

This module creates one EC2 instance in a public subnet and runs the real
`intern-task-app` container on it.

## Files

- `versions.tf` pins the AWS provider source and version and sets the minimum
  Terraform version.
- `variables.tf` defines inputs, including required `ssh_cidr`.
- `main.tf` defines the provider, network, security group, and EC2 instance.
- `user_data.sh.tftpl` bootstraps the instance on first boot.
- `outputs.tf` returns the instance public IP and application port.

The app source and Dockerfile are read from the sibling
`../intern-task-app/` directory when Terraform runs. Keep both challenge
directories together in the repository.

## Network and access

The VPC contains one subnet. The subnet is public because it has a default
route to an Internet Gateway and assigns public IPs to launched instances.
The instance also explicitly requests a public IP.

Inbound security group rules allow SSH (TCP 22) only from `ssh_cidr`, and
the app (TCP 5000) from anywhere. The host firewall applies the same intent:
the app port is open, and SSH is limited to `ssh_cidr`. Outbound traffic is
allowed so the instance can install packages and build the image.

## Instance bootstrap

EC2 receives `user_data.sh.tftpl` through the `user_data` argument. Terraform
embeds the actual app source and Dockerfile as base64 values; the script
decodes them into a build context and builds `intern-task-app:local`. It
creates `appuser` with passwordless sudo, installs and enables Docker, and
starts the container through an enabled systemd service.

The app listens on port 5000 because that is the `PORT` and `EXPOSE` value
in the app's Dockerfile. The container port mapping and both firewalls use
the `app_port` variable, whose default is 5000.

## User data and replacement

`user_data_replace_on_change = false` tells the AWS provider not to replace
the EC2 instance when user data changes. Cloud-init normally runs only on
first boot, so editing the bootstrap script does not automatically rerun it
on an existing instance. This setting also prevents an unrelated change from
causing user data to trigger instance replacement. Recreate the instance
intentionally if you need a changed bootstrap script to run on a fresh host.

## Local checks

Run from this directory. The README in the challenge root specifies fake
AWS credentials for planning without an AWS account.

```bash
export AWS_ACCESS_KEY_ID=fake
export AWS_SECRET_ACCESS_KEY=fake
export AWS_DEFAULT_REGION=us-east-1

terraform fmt -recursive
terraform init -backend=false
terraform validate
terraform plan -var='ssh_cidr=203.0.113.10/32'
bash -n user_data.sh.tftpl
```

The `ssh_cidr` above is a documentation-only example range. Replace it with
your own public IP in CIDR form, commonly `/32`, when using the module.
`terraform plan` does not deploy resources; do not run `terraform apply`
unless you intend to create them.
