# Docker (`docker run`)

← [Back to run/README](../README.md).

## kzero is not self-contained

**kzero** orchestrates the cluster by **shelling out** to **`kubectl`** (for workload steps) and **`helm`** (for **`release.*`** steps). Those binaries must exist on the **host** and match what you configure under **`command.kubectl`** / **`command.helm`** in YAML. A working **`kubeconfig`** (or in-cluster auth when run from a job runner that provides it) is **your** responsibility. The **kzero** binary alone — including the **GHCR** image — does **not** embed Kubernetes clients or Helm.

The published image (**[GHCR](https://github.com/hrodrig/kzero/pkgs/container/kzero)**) is **distroless**: only the **`kzero`** binary (no shell, no **`kubectl`**, no **`helm`**). **`analyze`** and **`version`** only read config and print summaries — they do **not** need **`kubectl`**. **`down`**, **`up`**, and **`reset`** in **`live`** mode **will** invoke **`kubectl`** / **`helm`** on **`PATH`**; use the **native package install** on a bastion or build a **custom image** that layers those tools if you insist on containers for **`live`**.

Examples use **`v0.4.1`**; pick a tag that exists on GHCR ([kzero releases](https://github.com/hrodrig/kzero/releases)).

### Bastion or automation host (binary)

**Recommended** for **`live`** pipelines: install **`kzero`**, **`kubectl`**, and (if your config uses **`release.*`** steps) **`helm`** on the same host; place **`kzero.yaml`** and a valid **`kubeconfig`**; set **`command.kubectl`** / **`command.helm`** to absolute paths when **`PATH`** is minimal ([kzero README — First run](https://github.com/hrodrig/kzero/blob/main/README.md#first-run)). Schedule with **cron** or **systemd** on that host — **not** inside the workload cluster as a substitute for real **`kubectl`** / **`helm`** installs.

```bash
kzero --config /etc/kzero/kzero.yaml analyze
kzero --config /etc/kzero/kzero.yaml down
```

### Config validation (`analyze`) in Docker

The stock image is useful when you only need **config validation** — **`analyze`** does not call **`kubectl`**. For anything **`live`**, use a host install (above) or a **custom image** that includes **`kubectl`** / **`helm`**.

You can mount **[`run/examples/kzero.sample.yml`](../examples/kzero.sample.yml)** from this repo or your own file:

```bash
docker run --rm \
  -v "$PWD/kzero.yaml:/config/kzero.yaml:ro" \
  ghcr.io/hrodrig/kzero:v0.4.1 \
  --config /config/kzero.yaml analyze
```

### Print version

```bash
docker run --rm ghcr.io/hrodrig/kzero:v0.4.1 version
```

**Check:** **`analyze`** prints **`Config:`**, **`Schema:`**, **`Run mode:`**, **`Run execution:`**, indexed **`[down]`** / **`[up]`** step lists, optional **Cluster validation** (when kubeconfig loads), and (when applicable) a **Deferred** block; non-fatal warnings may appear on **stderr**. Exit code **0** on success unless cluster validation reports **FAIL**. See [kzero SPEC — `kzero analyze`](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md#kzero-analyze).

---

**[↑ Back to run/README](../README.md)**
