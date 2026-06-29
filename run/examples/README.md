# Example configs and operator assets

| Path | Purpose |
|------|---------|
| **`kzero.sample.yml`** | Minimal **dry-run** profile for copy-paste |
| **`full-reset-example/`** | **Real-cluster** lab (**`kzero-demo`**): WordPress + Bitnami infra, **`install-demo.sh`**, live **`reset`** with truncate + PVC wipe |
| **`hooks/`** | Reference **`pre`** / **`post`** shell scripts |
| **`infra-probe/`** | Anonymous Redis probe chart script, values, sample YAML fragment |

**Full reset validation:** [run/docs/full-reset-validation.md](../docs/full-reset-validation.md) · anonymized [transcripts](../docs/transcripts/).

**Full annotated profile** (packaged in **`.deb`** / release tarballs): **[kzero `configs/kzero.sample.yml`](https://github.com/hrodrig/kzero/blob/main/configs/kzero.sample.yml)**.

**Schema and feature cookbooks** (notify, probe, verify): **[kzero SPECIFICATIONS](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md)** and **[docs/examples/](https://github.com/hrodrig/kzero/tree/main/docs/examples)**.

Examples assume **kzero** [v0.8.0+](https://github.com/hrodrig/kzero/releases/tag/v0.8.0) on the host (**v0.8.1** recommended). For **`docker run`**, see **[`run/docker/README.md`](../docker/README.md)**.

← [Back to run/README](../README.md)
