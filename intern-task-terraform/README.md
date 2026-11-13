# intern-task-terraform

Two things are missing here:

1. A Terraform module in `terraform/` — currently empty.
2. A working CI pipeline — `.github/workflows/intern-task-terraform-ci.yml`
   (at the repo root, not in this folder) exists, but it's broken
   independently of whatever Terraform you write. Fixing your Terraform
   alone will not make it pass.

Fork this repo, do both, and open a PR back against `main`. Everything for
this task lives under `intern-task-terraform/` plus that one workflow
file — you don't need to touch anything else.

Nothing here gets deployed for real — no AWS account needed, by you or by
us. We're checking that the Terraform is valid and demonstrates the right
concepts, not that it actually stood up infrastructure.

To make that possible, your `provider "aws" {}` block needs three extra
arguments: `skip_credentials_validation = true`,
`skip_requesting_account_id = true`, `skip_region_validation = true`. This
isn't something to figure out — it's just plumbing: it lets `terraform
plan` compute a real plan against fake credentials without ever calling
AWS, which is what you need to actually test this locally since nobody has
a real account here. CI itself only runs `fmt`/`validate` — see below.

This task builds on [`../intern-task-app/`](../intern-task-app/) — the
instance you provision here needs to actually run the app from that task,
not a stand-in service. You'll need that task's Dockerfile to exist (in
your branch — it doesn't need to be merged) before this one makes sense.
Do it first, or alongside.

## What the Terraform module must do

Using the [`aws`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
provider, describe a single EC2 instance, bootstrapped entirely via
`user_data` (cloud-init — no provisioner blocks).

**The instance itself**, via `user_data`, must:

- Create a non-root user with passwordless sudo.
- Install Docker, then build and run (as a proper systemd-managed
  container, survives a reboot) the image from `intern-task-app`'s
  Dockerfile — not a generic web server. However you get the Dockerfile
  and app source onto the instance (embed it, fetch it, whatever) is your
  call; it just has to be the real thing, built the same way it's built in
  the other task.
- Configure the host's own firewall so that only the port the app
  actually listens on is reachable — not "disable the firewall," not
  "allow everything." That port is whatever `intern-task-app`'s Dockerfile
  says it is, not a free choice anymore — check the other task's README
  if you haven't done it yet.

**Re-running `plan` must not show the instance needing replacement.** AWS
can't push updated `user_data` to an instance that's already running —
cloud-init only runs once, at first boot. The AWS provider's default
behavior for this attribute is to treat any change to it as a reason to
replace the instance. That means: change something unrelated elsewhere in
your config and re-run `terraform plan` — if it now wants to destroy and
recreate the instance because of `user_data`, you haven't solved this yet,
even if the module looks fine on a from-scratch plan. There's more than
one legitimate way to fix this (a resource-specific argument, or a more
general Terraform mechanism) — either is fine, but say which you picked
and why in the PR.

**Networking:**

- A VPC with a subnet, that's actually reachable from the internet — a
  CIDR block alone doesn't make a subnet public. Think about what else is
  required for that to be true, and make sure you've added it, not just
  the pieces that are easy to remember.
- A security group that only allows: SSH from one specific CIDR (make it a
  variable, don't hardcode an IP), and the app's actual port from anywhere.
  Nothing else. `0.0.0.0/0` on SSH is a fail here, not a shortcut.

**Outputs**: the instance's public IP, and the app's port.

Variables should have sensible defaults where a default makes sense (the
AMI ID, for instance — it's never actually launched, so any plausible
value is fine), and be required where a default would be actively
misleading (the SSH CIDR — there's no sane default for "my IP").

## What's wrong with the CI pipeline

Not telling you — that's the point. Read the workflow file itself; don't
assume a green check on your PR means it's fixed. CI only runs `fmt` and
`validate`, and neither of those actually exercises the pipeline's real
structural problems — a CI pass here is not the same as having found and
fixed them. There's more than one issue.

## Verifying it locally

No AWS account, no credentials, nothing to clean up afterward — all of
this only needs to parse and resolve correctly, never actually run.

```bash
cd terraform
export AWS_ACCESS_KEY_ID=fake
export AWS_SECRET_ACCESS_KEY=fake
export AWS_DEFAULT_REGION=us-east-1

terraform fmt -check
terraform init
terraform validate
terraform plan

# change something unrelated, then re-plan — this must NOT show the
# instance as needing replacement
terraform plan
```

Run this yourself before asking for review — CI does not. It only checks
`fmt`/`validate`, which is a much lower bar than this actually working.

## What we're looking for in the PR

- Does the instance actually run `intern-task-app`'s container, on that
  app's actual port — or did you build something that happens to satisfy
  the letter of the spec with a different service entirely?
- Is the subnet actually internet-reachable, or does it just have a CIDR
  block and nothing that makes it public?
- Is the security group actually least-privilege, or does it default to
  "open SSH to the world" because that's easier to not think about?
- How did you solve the user_data-forces-replacement problem, and can you
  explain why that mechanism exists rather than just that it works?
- Does the `user_data` script do what it claims — "installs and enables a
  service" should mean the service would actually be running, not just
  that the commands look plausible.
- Whether you fixed the pipeline's actual structural problems or just
  happened to write Terraform that doesn't trip over them.
- A PR description that separates what was wrong with the pipeline from
  what you did in the Terraform itself — two different problems, treat
  them that way in the writeup.
