# How to run kzero (self-hosted)

← [Back to the repository README](../../README.md).

Pick a **mode** below. **Install the CLI** from **[kzero releases](https://github.com/hrodrig/kzero/releases)** ( **[v0.9.0](https://github.com/hrodrig/kzero/releases/tag/v0.9.0)** recommended; **v0.8.0+** for **`run.api_watchdog`**). **This** repo holds operator docs and examples only.

| Directory | When to use |
|-----------|-------------|
| [`standalone/`](standalone/README.md) | **Release binary** on a bastion — cron, systemd timer, one-shot **down**/**up**/**reset** (no Docker) |
| [`docker/`](docker/README.md) | **`docker run`** with **`ghcr.io/hrodrig/kzero`** — **`analyze`** / **`version`**; not a full **live** runtime without host **`kubectl`** / **`helm`** |
| [`examples/`](examples/README.md) | Minimal **`kzero.sample.yml`**, **`full-reset-example/`**, reference **hooks**, **infra-probe** Redis assets |
| [`in-cluster/`](in-cluster/README.md) | **Job** + **ServiceAccount** + **RBAC** + **ConfigMap** — run **`kzero`** inside the cluster (native scale, no kubeconfig mount) |
| [`docs/`](docs/automation-and-pipelines.md) | **CI/cron**, **`KZERO_RUN_MODE`**, YES-gated wrappers, safety checklist · [**full-reset validation**](docs/full-reset-validation.md) |
| [`../testing/kind/`](../testing/kind/README.md) | Disposable **kind** cluster + **kzero** live smoke (**`make test-kind-e2e`**) |
| [`../testing/kind/in-cluster/`](../testing/kind/in-cluster/README.md) | **kind** + **kzero Jobs** in-cluster (**`make test-kind-in-cluster`**) |

**Upstream application:** **[hrodrig/kzero](https://github.com/hrodrig/kzero)** — Go CLI, SPEC, tests, **`make release-check`**, **`ghcr.io/hrodrig/kzero`** images, **`brew install hrodrig/kzero/kzero`**.

**Not shipped here:** Docker Compose, a Helm chart that installs **kzero** as a long-running in-cluster controller, or bundled **`kubectl`** / **`helm`** inside the runner image. **In-cluster Jobs** (reference manifests under **`run/in-cluster/`**) use the **distroless GHCR image** with **`run.execution: native`** only; **`release.*`** and shell hooks still need host tooling or future **Helm SDK** / **`exec`** steps in **kzero**.

Use a published image tag that matches your desired [kzero](https://github.com/hrodrig/kzero) release (in-cluster examples pin **`v0.9.0`**).

---

[↑ Back to the repository README](../../README.md)
