# How to run kzero (self-hosted)

← [Back to the repository README](../../README.md).

Pick a **mode** below. **Install the CLI** from **[kzero releases](https://github.com/hrodrig/kzero/releases)** ( **[v0.6.1+](https://github.com/hrodrig/kzero/releases/tag/v0.6.1)** recommended — man page, Homebrew, notify, verify, probe, preflight). **This** repo holds operator docs and examples only.

| Directory | When to use |
|-----------|-------------|
| [`standalone/`](standalone/README.md) | **Release binary** on a bastion — cron, systemd timer, one-shot **down**/**up**/**reset** (no Docker) |
| [`docker/`](docker/README.md) | **`docker run`** with **`ghcr.io/hrodrig/kzero`** — **`analyze`** / **`version`**; not a full **live** runtime without host **`kubectl`** / **`helm`** |
| [`examples/`](examples/README.md) | Minimal **`kzero.sample.yml`**, reference **hooks**, **infra-probe** Redis assets |
| [`docs/`](docs/automation-and-pipelines.md) | **CI/cron**, **`KZERO_RUN_MODE`**, YES-gated wrappers, safety checklist |
| [`../testing/kind/`](../testing/kind/README.md) | Disposable **kind** cluster + **kzero** live smoke (**`make test-kind-e2e`**) |

**Upstream application:** **[hrodrig/kzero](https://github.com/hrodrig/kzero)** — Go CLI, SPEC, tests, **`make release-check`**, **`ghcr.io/hrodrig/kzero`** images, **`brew install hrodrig/kzero/kzero`**.

**Not shipped here:** in-cluster Helm chart for **kzero**, Docker Compose stack, or bundled **`kubectl`** / **`helm`**. **kzero** runs on a **host** that already reaches the API server.

Use a published image tag that matches your desired [kzero](https://github.com/hrodrig/kzero) release (examples pin **`v0.6.1`**).

---

[↑ Back to the repository README](../../README.md)
