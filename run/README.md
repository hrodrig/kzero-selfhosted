# `run/` — operator docs for kzero

**kzero** is a **CLI** meant to run on a **trusted host** (bastion, automation VM, or CI worker). It is **not self-contained**: it invokes external **`kubectl`** and **`helm`** (see **`command.kubectl`** / **`command.helm`** in config) to mutate the cluster. Install those binaries on the host, keep a working **`kubeconfig`**, and add **`kzero`** on top. **`helm`** is only required if your pipeline includes **`release.*`** steps.

**kzero** is **not** deployed as an in-cluster workload, and **this repository does not ship a `run/kubernetes/` tree** (no Helm chart, no CronJob, no in-cluster manifests for the CLI).

This tree holds optional **operator-facing** material:

- **[`docker/`](docker/README.md)** — **`docker run`** for **`analyze`** / **`version`** on the distroless image (**not** a full **`live`** runtime).
- **[`examples/`](examples/README.md)** — minimal **`kzero.sample.yml`** for copy-paste.

**Production pattern:** install **`kzero`**, **`kubectl`**, and **`helm`** (if needed) from **[kzero releases](https://github.com/hrodrig/kzero/releases)** / your OS packages, keep **`kubeconfig`** on that host, and schedule **`kzero`** with **cron** or **systemd** outside the data plane cluster. See **[`run/docker/README.md`](docker/README.md#kzero-is-not-self-contained)**.

**Upstream:** application source and **`ghcr.io/hrodrig/kzero`** images are built from **[hrodrig/kzero](https://github.com/hrodrig/kzero)**. This repo (**kzero-selfhosted**) holds **docs and examples** only. For a **kind** smoke that runs **kzero** against synthetic workloads, see **[`../testing/kind/`](../testing/kind/README.md)**.

← [Back to repository README](../../README.md)
