# devops-challenge

## Antonio Puceski's solution — start here

The completed implementation is on **`solution/antonio-devops`**. If you opened
the fork's unchanged `main` branch, switch branches or open
[the solution directly](https://github.com/AntonioPuceski/devops-challenge/tree/solution/antonio-devops).

| What to inspect | Link |
| --- | --- |
| App design and commands to reproduce the deployment | [App solution](intern-task-app/SOLUTION.md) |
| Docker image definition | [Dockerfile](intern-task-app/Dockerfile) |
| Kubernetes deployment and Service | [Manifests](intern-task-app/k8s/) |
| Fresh local app check output | [App verification log](intern-task-app/evidence/local-checks.txt) |
| Terraform design, networking, firewall, lifecycle and CI fixes | [Terraform solution](intern-task-terraform/SOLUTION.md) |
| Terraform implementation and tests | [Module](intern-task-terraform/terraform/) |
| All observed verification results and limits | [Verification record](intern-task-terraform/VERIFICATION.md) |
| Actual local Terraform plan/test output | [Evidence files](intern-task-terraform/evidence/) |
| Repaired Terraform workflow | [Workflow](.github/workflows/intern-task-terraform-ci.yml) |

### What exists and what does not

- The app was built and deployed on a local kind Kubernetes cluster. Its Service
  endpoints returned the expected responses. A stalled request caused readiness
  failure, a liveness-triggered restart and recovery.
- Terraform's actual AWS provider produced plans using fake credentials. Mock
  tests exercised a tag update against simulated state, not a live EC2 instance.
- Cloud-init, shell syntax and the systemd unit passed local configuration checks.
- **There are no GitHub-hosted CI runs yet.** Local lint/validation results are
  not GitHub Actions checks. Opening the upstream PR and its resulting CI remain pending.
- **No AWS infrastructure was deployed.** No EC2 boot, reboot or live firewall
  enforcement test is claimed. This challenge does not require an AWS account.
- This is a tiny HTTP service returning text, not a visual website. There is no
  hosted application URL or dashboard to open. The public deliverable is the code,
  explanations and evidence below.
- The submission PR and recruiter email have not been sent. Submission confirms
  acceptance of the internship terms, which is still awaiting the applicant's decision.

### Application request path

```text
Local browser/curl -> kubectl port-forward -> Service port 80
                                              |
                                              v
                                      Pod TCP port 5000
                                      /healthz -> ok
                                      / -> hello from intern-task
```

### Terraform network and boot path

```text
Internet -> Internet gateway -> Public subnet + route table
                                 -> EC2 public IP
                                 -> Security group
                                 -> Host firewall (TCP 5000 only)
                                 -> App container using host networking

First boot: cloud-init -> Docker install -> embedded app build -> systemd service
```

The security group's restricted SSH rule does not override the app-only host
firewall. The resulting SSH limitation and the first-boot-only update policy are
explained explicitly in the Terraform solution notes.

---

## Original challenge overview

Two take-home challenges that build on each other, in separate folders:

- [`intern-task-app/`](intern-task-app/) — containerize and deploy a small
  app to Kubernetes. Do this one first.
- [`intern-task-terraform/`](intern-task-terraform/) — write an AWS
  Terraform module that provisions an instance to actually run the app
  from the task above. Needs that task's Dockerfile to exist in your
  branch first (doesn't need to be merged).

Each has its own README with the actual task.
