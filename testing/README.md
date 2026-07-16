# Testing (kzero-selfhosted)

| Directory | Purpose |
|-----------|---------|
| **[`kind/`](kind/README.md)** | **kind** cluster + sample workloads + **kzero** live **down**/**up** smoke (host binary) |
| **[`kind/in-cluster/`](kind/in-cluster/README.md)** | **kind** + **kzero Jobs** inside the cluster (**`make test-kind-in-cluster`**) |
| **`scripts/`** | Bash drivers (**`kzero-kind-e2e.sh`**, **`kzero-in-cluster-kind-smoke.sh`**) |

**Upstream:** application unit tests and **`make release-check`** live in **[hrodrig/kzero](https://github.com/hrodrig/kzero)** (use **kzero v1.0.1** — default **`run.execution: native`**, exit codes **0–4**, watchdog/notify, doctor, analyze). This tree only validates **kzero against a disposable kind cluster** using manifests committed here.

← [Back to repository README](../../README.md)
