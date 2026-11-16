Built on the `app` branch (PR [#96](https://github.com/atomityhq/devops-challenge/pull/96)) because the instance builds that task's Dockerfile.

Screenshot of the end of the plan output:  ![terraform plan output](https://github.com/Ananthapad77/devops-challenge/blob/terraform/intern-task-terraform/terraform/terraform-plan-screenshot.png?raw=true)



## Part 1: What was wrong with the pipeline
1. **No `working-directory`.** `terraform validate` ran at the repo root, which has no `.tf` files. `validate` succeeds on an empty directory, so CI was green while checking nothing. Fix: `defaults.run.working-directory: intern-task-terraform/terraform`.
2. **No `terraform init`.** `validate` needs the provider schemas that `init` downloads. This was hidden by problem 1. Fix: added `terraform init -backend=false -input=false`.
3. **The path filter did not include the workflow file** (or the app files the module reads), so editing the pipeline never ran the pipeline. Fix: added both to `paths`.
4. Hardening: `permissions: contents: read`, `concurrency`, a timeout, and a guard step that fails if the directory has no `.tf` files, so problem 1 can't silently come back.

## Part 2: The module
- VPC, public subnet, internet gateway, route `0.0.0.0/0` to the IGW, and the route table association. A subnet is only public with all three: IGW, route, and public IPs.
- Security group: SSH from `var.ssh_cidr` only (no default, and the validation rejects `0.0.0.0/0`), the app port from anywhere, outbound only 80/443.
- Cloud-init `user_data`: creates a non-root `deploy` user with passwordless sudo, installs Docker, builds the real `intern-task-app/Dockerfile`, runs it from a systemd unit, and sets a ufw firewall (default deny; allow 22 and the app port).
- The port is read from the Dockerfile's `EXPOSE` line, so the security group, ufw and the container can't disagree.
- The container runs with `--network host`. With `-p`, Docker's iptables rules bypass ufw, which would make the host firewall decorative.

## The `user_data` replacement problem
I used `lifecycle { ignore_changes = [user_data] }`. cloud-init only runs `user_data` at first boot, so editing it can never change a running instance. Without this, an edit would show up as a change to the instance. `user_data_replace_on_change = false` only changes how the provider applies the change (in-place stop/start), so the plan would still show a modification. The trade-off is that bootstrap edits are silently not applied; to roll one out deliberately, run `terraform apply -replace=aws_instance.app`.

I did not put `ssh_cidr` in ufw. If I had, changing the security group CIDR would also edit `user_data`, which is ignored, so ufw would keep the old rule while the security group changed.

## How I verified

Run in `intern-task-terraform/terraform` with fake AWS credentials. Nothing was applied or created in AWS.

```
terraform init
terraform validate     -> Success! The configuration is valid.
terraform plan -var ssh_cidr=203.0.113.7/32
  -> Plan: 12 to add, 0 to change, 0 to destroy.
  -> app_port = 5000
```


PASTE THE SCREENSHOT HERE

## Not verified
- I did not run `terraform apply`, so the bootstrap script has not been run on a real EC2 instance.
- The AMI default is a placeholder Ubuntu image ID.
- The image is built on the instance and needs outbound 443 to pull the Python base image.
