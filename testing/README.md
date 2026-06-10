# Testing (kzero-selfhosted)

| Directory | Purpose |
|-----------|---------|
| **[`kind/`](kind/README.md)** | **kind** cluster + sample workloads (**Postgres**, **Redis**, **RabbitMQ**, lab **counter** + nginx **web**, nginx **StatefulSet**, **obs** **Deployment**) + **kzero** live **down**/**up** smoke |
| **`scripts/`** | Bash drivers (e.g. **`kzero-kind-e2e.sh`**) |

**Upstream:** application unit tests and **`make release-check`** live in **[hrodrig/kzero](https://github.com/hrodrig/kzero)** (use **kzero v0.6.1+** for notify, verify, probe, preflight, and current **`run.execution`** behavior). This tree only validates **kzero against a disposable kind cluster** using manifests committed here.

← [Back to repository README](../../README.md)
