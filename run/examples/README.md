# Example configs

- **`kzero.sample.yml`** — minimal **dry-run** pipeline for copy-paste; align with **[kzero SPECIFICATIONS](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md)**. **`kzero analyze`** (v0.4.1+) lists **`[down]`** / **`[up]`** steps, **`Run execution:`**, optional **Cluster validation** (when kubeconfig loads), and **Deferred** fields on stdout. **`live`** runs need **`kubectl`** / **`helm`** on the host when **`run.execution`** is **`shell`** or **`auto`** (fallback); **`native`** uses client-go only for workload steps — see **[`run/docker/README.md`](../docker/README.md)**.

← [Back to run/README](../README.md)
