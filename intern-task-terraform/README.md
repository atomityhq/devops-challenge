# Intern Task Terraform – AWS EC2 Infrastructure

## Overview

This project implements the Terraform infrastructure and CI pipeline for the Atomity Cloud & DevOps Intern challenge.

The solution provisions a public AWS network and a single EC2 instance configured through cloud-init (`user_data`). The instance installs Docker, builds the actual application from Part One (`intern-task-app`), and runs it as a persistent systemd-managed container.

**No AWS deployment is required for this challenge.** The Terraform configuration is initialized, validated, and planned locally using fake AWS credentials.

## Architecture

The infrastructure consists of:

- **VPC:** Dedicated network with CIDR `10.0.0.0/16`.
- **Public subnet:** CIDR `10.0.1.0/24`, configured to assign public IPv4 addresses.
- **Internet Gateway:** Provides internet connectivity to the VPC.
- **Public route table:** Routes outbound internet traffic through the Internet Gateway.
- **Security group:** Allows SSH only from a configurable administrator CIDR and application traffic on port `8080`.
- **EC2 instance:** Ubuntu 22.04 AMI, `t3.micro`, public IP, encrypted GP3 root volume, and IMDSv2 enforcement.

### Network flow

\`\`\`text
Internet
   |
   v
Internet Gateway
   |
   v
Public Route Table
   |
   v
Public Subnet (10.0.1.0/24)
   |
   v
Security Group
   |                  |
   | SSH (22)         | Application (8080)
   | Restricted CIDR  | Public access
   |                  |
   +--------+---------+
            |
            v
       EC2 Instance
            |
            v
       Docker Engine
            |
            v
      intern-task-app
\`\`\`

## Project structure

\`\`\`text
intern-task-terraform/
├── README.md
└── terraform/
    ├── .gitignore
    ├── .terraform.lock.hcl
    ├── versions.tf
    ├── variables.tf
    ├── main.tf
    ├── ec2.tf
    ├── outputs.tf
    └── bootstrap/
        ├── Dockerfile
        ├── user_data.sh.tftpl
        └── app/
            └── app.py
\`\`\`

The Dockerfile and application source are copied from Part One so that the EC2 instance builds and runs the actual challenge application rather than a substitute web server.

## Infrastructure implementation

### 1. Provider configuration

The AWS provider uses three required flags:

- \`skip_credentials_validation = true\`
- \`skip_requesting_account_id = true\`
- \`skip_region_validation = true\`

These allow Terraform to generate a plan using fake credentials without requiring a real AWS account.

### 2. Public networking

The module creates:

- A VPC.
- A public subnet.
- An Internet Gateway.
- A route table with a default route to the Internet Gateway.
- A route table association.
- Automatic public IPv4 assignment for instances launched in the subnet.

The Internet Gateway, default route, and route table association are important: a subnet CIDR alone does not make a subnet publicly reachable.

### 3. Security group

Only two inbound rules are configured:

| Protocol | Port | Source |
|---|---:|---|
| TCP | 22 | Configurable \`ssh_cidr\` |
| TCP | 8080 | \`0.0.0.0/0\` |

SSH is not exposed to the entire internet.

Outbound traffic is allowed so that the instance can install packages and retrieve required dependencies during bootstrap.

### 4. EC2 bootstrap

The instance uses Terraform's \`templatefile()\` function to supply the real Part One Dockerfile and application source to the cloud-init template.

The bootstrap script performs these operations:

1. Updates Ubuntu package indexes.
2. Installs Docker, UFW, sudo, and required certificates.
3. Enables and starts Docker.
4. Creates a dedicated non-root \`internadmin\` user.
5. Adds the user to the sudo and Docker groups.
6. Configures passwordless sudo for the dedicated administrator.
7. Reconstructs the application source and Dockerfile under \`/opt/intern-task-app\`.
8. Builds the actual \`intern-task-app\` Docker image.
9. Configures UFW to deny incoming traffic by default.
10. Allows SSH only from the configured administrator CIDR.
11. Allows application traffic on port \`8080\`.
12. Creates and enables a systemd service to manage the application container.

The container uses host networking so that the host firewall can filter inbound application traffic directly, avoiding the common issue of Docker-published ports bypassing UFW rules.

The Dockerfile from Part One also runs the application as a non-root container user.

### 5. Persistent systemd service

The application runs through:

\`/etc/systemd/system/intern-task-app.service\`

The service:

- Starts after Docker and network initialization.
- Starts the application container.
- Restarts the container automatically if it exits.
- Is enabled for system startup.

This makes the application persistent across instance reboots.

## Handling user_data replacement

The EC2 resource explicitly sets:

\`\`\`hcl
user_data_replace_on_change = false
\`\`\`

The AWS provider can otherwise replace an EC2 instance when its \`user_data\` changes.

This resource-specific argument prevents replacement solely because of a user-data change.

**Important operational consideration:** AWS does not automatically rerun cloud-init when updated user data is supplied to an existing running instance. Therefore, changing the bootstrap template does not automatically apply those new commands to an existing server. An explicit configuration-management or redeployment process would be needed to apply such changes.

This approach satisfies the challenge's requirement to avoid instance replacement due to user-data changes.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| \`aws_region\` | \`us-east-1\` | AWS deployment region |
| \`ami_id\` | Ubuntu 22.04 AMI ID | EC2 operating system image |
| \`instance_type\` | \`t3.micro\` | EC2 instance size |
| \`ssh_cidr\` | Required | Administrator IPv4 CIDR |
| \`app_port\` | \`8080\` | Application listening port |

The SSH CIDR is deliberately required rather than defaulting to an unrestricted or misleading address.

The AMI ID is a plausible example for \`us-east-1\`; it may need to be updated if the configuration is used in another region.

## Outputs

The module exposes:

- \`instance_public_ip\` – Public IPv4 address of the EC2 instance.
- \`app_port\` – Application listening port.

## CI pipeline corrections

The original workflow had structural problems independent of the Terraform configuration.

### Problems identified

1. Terraform commands ran from the repository root instead of the module directory.
2. \`terraform validate\` ran before Terraform initialization.
3. Workflow path filters did not include the workflow file itself, so changes to the pipeline would not trigger it.

### Corrections implemented

The updated workflow:

- Uses \`intern-task-terraform/terraform\` as its working directory.
- Runs \`terraform init -backend=false\` before validation.
- Runs \`terraform fmt -check -recursive\`.
- Runs \`terraform validate\`.
- Triggers when the Terraform module or its own workflow file changes.
- Supports manual execution through \`workflow_dispatch\`.

CI intentionally performs formatting and validation only. A successful CI run does not replace the local planning checks described below.

## Local verification

### Prerequisites

- Terraform CLI.
- Git.
- Docker is required only if independently testing the application container.
- No AWS account or real AWS credentials are required.

### 1. Navigate to the Terraform module

\`\`\`bash
cd intern-task-terraform/terraform
\`\`\`

### 2. Configure fake AWS credentials

\`\`\`bash
export AWS_ACCESS_KEY_ID="fake"
export AWS_SECRET_ACCESS_KEY="fake"
export AWS_DEFAULT_REGION="us-east-1"
\`\`\`

### 3. Format Terraform files

\`\`\`bash
terraform fmt -recursive
terraform fmt -check -recursive
\`\`\`

### 4. Initialize Terraform

\`\`\`bash
terraform init -backend=false
\`\`\`

### 5. Validate the configuration

\`\`\`bash
terraform validate
\`\`\`

### 6. Generate an execution plan

\`\`\`bash
terraform plan -var="ssh_cidr=203.0.113.10/32"
\`\`\`

\`203.0.113.10/32\` is a reserved documentation address used only as an example for local planning. For a real deployment, replace it with the administrator's actual public IPv4 address in \`/32\` notation.

### 7. Review the replacement strategy

The EC2 resource contains:

\`\`\`hcl
user_data_replace_on_change = false
\`\`\`

This explicitly controls the provider's replacement behavior for user-data changes.

Because this challenge does not require an AWS deployment, no instance is created or applied locally. Consequently, a real stateful before-and-after replacement test cannot be performed against a running instance here. The replacement behavior is implemented through the resource-specific provider argument and can be verified against an existing instance in an AWS-backed test environment.

**Do not run \`terraform apply\` for this challenge.**

## Security decisions

- SSH ingress is restricted to a configurable CIDR.
- The application port is the only other inbound security-group rule.
- UFW denies incoming traffic by default.
- Docker container execution uses the non-root user defined in the application Dockerfile.
- A dedicated administrator account is created on the host.
- The root EBS volume is encrypted using GP3.
- EC2 metadata requires IMDSv2 tokens.
- No Terraform provisioners are used.
- No real AWS credentials are embedded in the repository.

## Challenge scope

This implementation is limited to:

- \`intern-task-terraform/**\`
- \`.github/workflows/intern-task-terraform-ci.yml\`

It builds on the application created in \`intern-task-app\` and does not require modifying unrelated challenge components.

## Final verification checklist

- [x] Terraform AWS provider configured with all three skip flags.
- [x] Terraform module implemented.
- [x] Public VPC and subnet configured.
- [x] Internet Gateway and default route configured.
- [x] Public route table association configured.
- [x] Security group restricted to the required inbound ports.
- [x] SSH CIDR supplied through a required variable.
- [x] Actual Part One Dockerfile and application source included.
- [x] Docker installed and application image built through user data.
- [x] Dedicated non-root administrator with passwordless sudo.
- [x] UFW host firewall configured.
- [x] Application managed through systemd.
- [x] Instance replacement behavior explicitly controlled.
- [x] Public IP and application port outputs defined.
- [x] Terraform formatting successful.
- [x] Terraform initialization successful.
- [x] Terraform validation successful.
- [x] Terraform plan successful using fake credentials.
- [x] CI working directory corrected.
- [x] CI initialization step added before validation.
- [x] Workflow path filters corrected.

**Deployment status:** Not deployed to AWS. Terraform formatting, initialization, validation, and planning have been completed locally.
