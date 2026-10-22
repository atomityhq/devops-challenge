# argocd

GitOps deployment of `intern-task-app` to multiple environments.

```
argocd/
├── project.yaml          # AppProject: allowed repo, namespaces, resource kinds
├── applicationset.yaml   # generates one Application per env (dev/staging/prod)
├── charts/web-app/       # reusable chart — no app-specific values inside
│   └── templates/        # one file per resource: deployment, service,
│                         #   configmap, secret, hpa
└── values/
    ├── base.yaml         # what intern-task-app is (image, port, UID, ...)
    ├── dev.yaml          # per-env overrides only
    ├── staging.yaml
    └── prod.yaml
```

Values are layered: chart defaults → `values/base.yaml` → `values/<env>.yaml`.
Each env deploys to namespace `intern-task-app-<env>`.

## Bootstrap

```bash
kubectl apply -n argocd -f argocd/project.yaml -f argocd/applicationset.yaml
```

Argo CD then syncs every env from `main`. After that, git is the only way to
change a deployment:

- **Promote a release:** bump `image.tag` in `values/<env>.yaml`.
- **Add an env:** add `values/<env>.yaml` and one element to the
  ApplicationSet's list generator.
- **Secrets:** dev uses an inline dummy value. Staging/prod expect a Secret
  named `intern-task-app-secret` created out-of-band (External Secrets /
  Sealed Secrets). Real secrets never go in git.

## Render locally (what Argo CD will apply)

```bash
helm template intern-task-app argocd/charts/web-app -n intern-task-app-prod \
  -f argocd/values/base.yaml -f argocd/values/prod.yaml
```

`k8s/` stays as plain manifests for the take-home's local `kind` check.
