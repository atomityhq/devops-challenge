# Verification record

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
