# Example configs and operator assets

| Path | Purpose |
|------|---------|
| **`kzero.sample.yml`** | Minimal **dry-run** profile for copy-paste |
| **`full-reset-example/`** | **Real-cluster** lab (**`kzero-demo`**): WordPress + Bitnami infra, **`install-demo.sh`**, live **`reset`** with truncate + PVC wipe |
| **`platform-reset/`** | **Large lab profile** (**`platform`**): anonymized multi-tier apps + 8 Helm releases, hooks, full **`helm/`** workspace, live reset fixture log |
| **`hooks/`** | Reference **`pre`** / **`post`** shell scripts |
| **`infra-probe/`** | Anonymous Redis probe chart script, values, sample YAML fragment |

**Full reset validation:** [run/docs/full-reset-validation.md](../docs/full-reset-validation.md) · anonymized [transcripts](../docs/transcripts/).

**Full annotated profile** (packaged in **`.deb`** / release tarballs): **[kzero `configs/kzero.sample.yml`](https://github.com/hrodrig/kzero/blob/main/configs/kzero.sample.yml)**.

**Schema and feature cookbooks** (notify, probe, verify): **[kzero SPECIFICATIONS](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md)** and **[docs/examples/](https://github.com/hrodrig/kzero/tree/main/docs/examples)**.

Examples assume **kzero** [v1.0.1+](https://github.com/hrodrig/kzero/releases/tag/v1.0.1) on the host. For **`docker run`**, see **[`run/docker/README.md`](../docker/README.md)**.

← [Back to run/README](../README.md)
