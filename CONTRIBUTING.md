# Contributing (kzero-selfhosted)

## Scope

- **This repo:** Operator docs, **`run/docker/`**, **`run/examples/`**, and optional **kind** e2e under **`testing/`**. Documents that **kzero** depends on external **`kubectl`** / **`helm`** and is **not** a self-contained cluster runtime. **No** Docker Compose, Helm charts for in-cluster **kzero**, or Kubernetes manifests that run the CLI inside the cluster.
- **[hrodrig/kzero](https://github.com/hrodrig/kzero):** Go application, **`make release-check`**, tests, and container images.

## Checks

- **This repo:** optional **`make test-kind-workloads`** (kind + manifests only) or **`make test-kind-e2e`** (includes **kzero** — see **`testing/kind/README.md`**).
- **kzero application:** clone **[hrodrig/kzero](https://github.com/hrodrig/kzero)** and run **`make release-check`** there.

## Pull requests

- Keep **English** in all committed text.
- When **`run/examples/kzero.sample.yml`** changes, confirm it still matches **[docs/SPECIFICATIONS.md](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md)** in the **kzero** repo.
- When **`testing/kind/`** manifests or **`kzero-e2e*.yaml`** change, run **`make test-kind-workloads`** (or **`make test-kind-e2e`** if you have **kzero** installed) before merging.

## Security

Report sensitive issues per **[SECURITY.md](SECURITY.md)**.

Community interaction: **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)**. Notable repo changes: **[CHANGELOG.md](CHANGELOG.md)**.
