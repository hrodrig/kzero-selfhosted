# kind smoke — kzero in-cluster Jobs

Runs **`kzero`** **inside** the cluster as **Kubernetes Jobs** (not from the host shell). Exercises **`run/in-cluster/`** manifests: **ServiceAccount**, **ClusterRole**, **ConfigMap**, and **`analyze` → `down` → `up`** across **`kzero-smoke-a`** and **`kzero-smoke-b`**.

← [Back to kind README](../README.md)

## Target

| Make target | Script |
|-------------|--------|
| **`make test-kind-in-cluster`** | **`testing/scripts/kzero-in-cluster-kind-smoke.sh`** |

## Prerequisites

- **Docker**, **kind**, **kubectl** on `PATH`
- **kzero image** with **InClusterConfig** when **`run.kubeconfig`** is empty (**`v0.7.0+`** minimum; examples pin **`v0.9.0`**, or build locally — see below)

**Does not** require the **kzero** binary on the host (unlike **`make test-kind-e2e`**).

## Phases

1. Create kind cluster (**`KZERO_KIND_IN_CLUSTER_CLUSTER`**, default **`kzero-in-cluster-smoke`**).
2. **Pull** (or **build**) the runner image and **`kind load`** it.
3. Apply **`run/in-cluster/manifests/`** (namespaces, RBAC, workloads, ConfigMap).
4. Job **`kzero-analyze`** — plan + cluster validation.
5. Job **`kzero-down`** — scale both Deployments to **0**.
6. Job **`kzero-up`** — scale back to **1** with **`wait_for_ready`**.

## Environment

| Variable | Default | Purpose |
|----------|---------|---------|
| **`KZERO_KIND_IN_CLUSTER_CLUSTER`** | **`kzero-in-cluster-smoke`** | kind cluster name |
| **`KZERO_IN_CLUSTER_IMAGE`** | **`ghcr.io/hrodrig/kzero:v0.9.0`** | Job container image (must match loaded image) |
| **`KZERO_IN_CLUSTER_BUILD`** | unset | Set to **`1`** to **`docker build`** from **`KZERO_REPO`** instead of pull |
| **`KZERO_REPO`** | **`../kzero`** if present | Path to **[hrodrig/kzero](https://github.com/hrodrig/kzero)** clone for local build |
| **`KZERO_KIND_JOB_TIMEOUT`** | **`300s`** | **`kubectl wait`** for each Job |
| **`KZERO_KIND_ROLLOUT_TIMEOUT`** | **`120s`** | Smoke workload rollouts |
| **`KZERO_KIND_NO_CLEANUP`** | unset | Keep kind cluster after run (debug) |

### Local kzero build (InClusterConfig not yet on GHCR)

```bash
export KZERO_IN_CLUSTER_BUILD=1
export KZERO_REPO=/path/to/kzero
export KZERO_IN_CLUSTER_IMAGE=kzero-in-cluster:local
make test-kind-in-cluster
```

## Manual debug

After a failed run with **`KZERO_KIND_NO_CLEANUP=1`**:

```bash
kubectl config use-context kind-kzero-in-cluster-smoke
kubectl get jobs,pods -n kzero-system
kubectl logs -n kzero-system job/kzero-analyze
kubectl get deploy -n kzero-smoke-a app -o wide
kubectl get deploy -n kzero-smoke-b app -o wide
```

## Related

- **Manifests and RBAC notes:** [`run/in-cluster/README.md`](../../../run/in-cluster/README.md)
- **Host-side kind e2e** (kzero on workstation): [`../README.md`](../README.md)

---

[↑ Back to kind README](../README.md)
