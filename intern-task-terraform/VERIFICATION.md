# Verification record

## Requirement audit

| Challenge requirement | Implementation / evidence |
| --- | --- |
| Fork and PR targeting upstream `main` | Public fork exists; upstream PR is the submission step, prepared separately |
| Dockerfile runs supplied app | `../intern-task-app/Dockerfile`; source `app/app.py` is unchanged |
| Deployment name and pod labels | `../intern-task-app/k8s/deployment.yaml`: `intern-task-app`, `app: intern-task-app` |
| Readiness and liveness `/healthz` | Both HTTP probes target the named `http` port; deliberate-stall recovery observed |
| Service name, selector, port 80 | `../intern-task-app/k8s/service.yaml`; named target resolves to 5000 |
| Runtime port consistency | Dockerfile, Deployment environment, container port, probes, Service and Terraform all use 5000 |
| Local image, no registry pulls | `imagePullPolicy: Never`; image loaded using kind before apply |
| Clean local deployment | Successful rollout and Service HTTP checks, without manifest patching |
| Optional image/user/resource choices explained | App `SOLUTION.md`: UID 10001, resource limits, slim image; no unnecessary multi-stage build |
| AWS provider with three required skip flags | `terraform/versions.tf`; fake-credential plans succeed |
| Exactly one EC2 instance, no provisioners | `aws_instance.app` in `terraform/main.tf`; cloud-init only |
| Non-root user with passwordless sudo | `intern` user in cloud-init, locked password and explicit sudo rule |
| Install Docker and build the real app | Cloud-init embeds sibling Dockerfile/source and runs `docker build` |
| Systemd-managed container and reboot startup | Enabled unit, Docker dependency, `Restart=always`, explicit start; static unit validation passed |
| Host firewall allows only app port | UFW denies incoming, allows TCP 5000; host networking avoids Docker port-publish bypass |
| Stable instance across unrelated changes | `ignore_changes = [user_data]`, replacement flag false; mock-state tag update preserves actual generated ID |
| Internet-reachable subnet | VPC, subnet, internet gateway, default route, association, public instance IP |
| Restricted SSH CIDR variable | Required `ssh_cidr`, no default; rejects world-open IPv4 CIDR |
| Only SSH and app security-group ingress | Two TCP rules; no extra ingress rules |
| Public IP and app port outputs | `terraform/outputs.tf`; extra instance-ID output supports identity testing |
| Sensible defaults | Region, illustrative Ubuntu AMI, instance type and name have defaults |
| CI structural fixes | Correct working directory, initialized locked provider, workflow/app dependency trigger paths |
| Local fmt/init/validate/plan and re-plan | Published Terraform logs and three mock tests; no real AWS apply |
| Explain CI separately from infrastructure | Terraform `SOLUTION.md` and prepared PR description |
| Public link without login | Public fork and raw verification file checked anonymously |

## Observed local results

Verified locally on Windows with Docker Desktop, a disposable kind cluster,
Terraform 1.12.0 and AWS provider 5.100.0. No real AWS resources were created.

| Check | Observed result |
| --- | --- |
| Docker build | Succeeded for `intern-task-app:local` |
| Image user | Python reported UID 10001 |
| `PORT=8080` override | `/healthz` returned `ok`; `/` returned `hello from intern-task` |
| kind deployment | Rollout succeeded; pod 1/1 Ready |
| Service port-forward | Both expected HTTP responses received through Service port 80 |
| kubeconform 0.6.7 strict | 2 valid resources; 0 invalid/errors/skipped |
| Stalled HTTP request | Readiness failed, liveness failed, container restarted once and pod returned 1/1 Ready |
| Terraform fmt/validate | Passed |
| Real provider, fake-credential initial plan | 7 to add, 0 to change, 0 to destroy |
| Real provider, fake-credential renamed-tag plan with no state | 7 to add, 0 to change, 0 to destroy |
| Mocked lifecycle test with simulated existing state | Instance updated in place; 0 to add, 3 tag updates, 0 to destroy |
| Mock tests overall | 3 passed, 0 failed, including rejected `0.0.0.0/0` SSH input |
| actionlint 1.7.7 | Repaired Terraform workflow passed |
| Ubuntu 24.04 cloud-init schema | Final rendered cloud-config passed |
| Bootstrap shell / systemd unit | `sh -n` and `systemd-analyze verify` passed in disposable Ubuntu with Docker installed |

The initial attempt to simulate a hang by signaling PID 1 did not stop the
process. The successful test used an incomplete HTTP request, as documented in
`../intern-task-app/SOLUTION.md`; observed probe failures and recovery above refer
to that test. It also demonstrates the supplied server's single-request limitation.

The mock test's final rejected-CIDR case prints a planning failure by design;
`expect_failures` verifies that rejection, and the overall test result passes.

Cloud-init was rendered and schema-checked, not booted on EC2. Neither systemd
reboot recovery nor host firewall enforcement was exercised on a real instance.
Those are configuration-level checks, not claims of a live AWS deployment.
GitHub-hosted CI is reported separately from these local checks.

## Inspect the evidence

- [Initial real-provider plan](evidence/terraform-plan.txt): seven proposed creates;
  no AWS apply took place.
- [Renamed-tag real-provider plan](evidence/terraform-plan-renamed.txt): also starts
  without state, so it cannot by itself establish update behavior.
- [Verbose mock test output](evidence/terraform-tests.txt): includes the simulated
  state and the subsequent in-place update plan. Random IDs/IP-like strings in
  this file are mock values, not live resource identifiers or usable endpoints.
- [Fresh local app checks](../intern-task-app/evidence/local-checks.txt): build,
  user identity, live cluster status, Service HTTP requests and schema/lint checks.

These are local command outputs, not GitHub Actions artifacts. The earlier
cloud-init/systemd and failure-recovery checks were observed in the execution
session; full raw transcripts of those earlier commands were not archived.
Local absolute paths to validator executables were shortened in the app log;
the command results are unchanged. No credentials or real cloud state are included.
