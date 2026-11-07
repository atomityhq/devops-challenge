# AWS Infrastructure · Terraform & CI

**Public networking · Restricted ingress · systemd container · Offline planning**

Defines one EC2 instance that builds and runs the same Python application from `intern-task-app/`.

## Design Decisions

| Choice | Reason |
|---|---|
| Public subnet + internet gateway + default route | Provides the network path needed for internet access. |
| Required `ssh_cidr` | Avoids a misleading default or world-open SSH rule. |
| Embedded application sources | Builds the actual Dockerfile without depending on a branch URL or registry. |
| systemd-managed container | Starts at boot and restarts when the container exits. |
| Host networking + UFW | Applies host firewall rules directly to application traffic on port `8080`. |
| `ignore_changes = [user_data]` | Preserves initial bootstrap configuration on existing instances. Later bootstrap changes require deliberate replacement or configuration management. |

The security group permits restricted SSH and public application traffic. The host firewall permits only the application port, following the task's stricter host-firewall requirement; SSH remains blocked at the host.

## Verification

From `intern-task-terraform/terraform/`:

```bash
export AWS_ACCESS_KEY_ID=fake
export AWS_SECRET_ACCESS_KEY=fake
export AWS_DEFAULT_REGION=us-east-1
export AWS_EC2_METADATA_DISABLED=true

terraform fmt -check -recursive
terraform init -backend=false -input=false -lockfile=readonly
terraform validate
bash -n templates/user_data.sh.tftpl
terraform plan -var="ssh_cidr=203.0.113.10/32"
```

| Check | Result |
|---|---|
| Formatting and validation | Passed |
| Bootstrap Bash syntax | Passed |
| Plan with fake credentials | `7 to add, 0 to change, 0 to destroy` |
| Outputs | Application port `8080`; public IP known after apply |
| Unrelated name change | Generated `user_data` remained identical |

No AWS resources were deployed. The AMI default is a placeholder and must be replaced before deployment. Runtime bootstrap, reboot persistence, and replacement behavior against deployed state were not exercised.

## CI Repairs

- Runs Terraform commands in the correct directory.
- Initializes providers before validation.
- Uses the committed provider lock file.
- Triggers on workflow changes and the application source files consumed by Terraform.
- Uses read-only repository permissions.

The workflow checks formatting and configuration validity; local verification also includes planning and bootstrap syntax checks.
