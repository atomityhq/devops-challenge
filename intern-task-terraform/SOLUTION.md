# Terraform and CI solution

## Infrastructure and bootstrap

Seven resources describe one EC2 instance, a VPC, a public subnet, an internet
gateway, a default route table, its subnet association and a security group.
The instance receives a public IP and waits for the route association before
creation so first-boot package installation has an internet route.

The Ubuntu 24.04 cloud-config embeds the actual sibling Dockerfile and app as
base64, avoiding a dependency on a public Git branch at boot. It creates the
locked-password `intern` user with passwordless sudo, installs Docker and UFW,
builds the image, and enables and starts a systemd service. `Restart=always`
recovers the container; enabling the unit starts it after reboot. Bootstrap uses
`set -eu` so a failed installation/build command cannot silently be skipped.

The container retains the image's non-root user. Host networking makes traffic
use the host INPUT chain instead of Docker's published-port forwarding rules,
which can bypass UFW. UFW denies incoming traffic except TCP 5000 and permits
outbound traffic for DNS, packages and image downloads.

There is a deliberate distinction in the requirements: the security group allows
TCP 5000 from anywhere and SSH only from required `ssh_cidr`, while the host
firewall is app-only. Therefore SSH is **not reachable end to end**, even from
that CIDR. No SSH key is configured. This honors the app-only host requirement;
a real operational SSH requirement would need an explicit host-rule/key change.
The CIDR validator permits IPv4 /24 through /32 and rejects world-open SSH.

## Instance stability

`lifecycle.ignore_changes = [user_data]` treats cloud-init as first-boot data.
Subsequent bootstrap edits are deliberately ignored on existing instances;
an intentional rollout requires `terraform apply -replace=aws_instance.app`.
`user_data_replace_on_change = false` also makes the replacement policy explicit.
The template contains no timestamps or other changing inputs.

For the pinned AWS provider 5.100.0, the documented default for changed user data
is stop/start when replacement is false, not unconditional replacement. Stop/start
still does not rerun ordinary once-per-instance cloud-init. Ignoring later changes
avoids implying that edited bootstrap data updates an existing host.
Reference: [AWS provider instance documentation](https://github.com/hashicorp/terraform-provider-aws/blob/v5.100.0/website/docs/r/instance.html.markdown).

## CI defects repaired separately

1. Terraform commands previously ran at repository root, outside the module.
   The job now sets `intern-task-terraform/terraform` as its run directory.
2. Validation had no provider initialization. `init -backend=false -input=false
   -lockfile=readonly` now installs the locked provider before validation.
3. Workflow-only edits did not trigger CI. Both push and PR filters now include
   the workflow itself, plus the app source and Dockerfile consumed by the module.

The job has read-only repository permissions. Terraform stays at the challenge's
1.12.0 version, and the committed provider lock includes Windows and Linux
checksums. CI remains fmt/validate; local plan and runtime results are separate.

## Reproduce without AWS

From `intern-task-terraform/terraform/` (Bash syntax):

```bash
export AWS_ACCESS_KEY_ID=fake AWS_SECRET_ACCESS_KEY=fake
export AWS_DEFAULT_REGION=us-east-1
export TF_VAR_ssh_cidr=203.0.113.10/32
terraform fmt -check -recursive
terraform init -backend=false -input=false -lockfile=readonly
terraform validate
terraform plan -input=false
terraform plan -input=false -var='name=intern-task-app-renamed'
terraform test -verbose
```

The documentation-only CIDR above is for planning; replace it with your trusted
CIDR for any real use. The AMI is illustrative, as permitted by the challenge;
verify its availability and Ubuntu version before considering a deployment.
Do **not** apply the ordinary module with fake credentials.

Two plans with no existing state both propose creates; they do not prove update
behavior. `tests/lifecycle.tftest.hcl` therefore uses Terraform's mock AWS provider
to create simulated state, then plan a tag change against that state. It verifies
instance identity and stable bootstrap data, and separately rejects world-open
SSH. Mock apply does not contact AWS or launch resources. The verbose plan should
show in-place tag updates and zero destroys. This is not a real AWS apply/reboot
test; the task explicitly requires no cloud account.
