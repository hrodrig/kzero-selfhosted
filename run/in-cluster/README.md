# Run kzero inside the cluster (Job + ServiceAccount)

Run **`kzero`** as a **Kubernetes Job** using the **distroless** **[GHCR image](https://github.com/hrodrig/kzero/pkgs/container/kzero)**, **`run.execution: native`**, and **in-cluster API credentials** (no bastion, no kubeconfig Secret mount).

← [Back to run README](../README.md)

## Prerequisites

| Requirement | Notes |
|-------------|--------|
| **kzero image** | **`ghcr.io/hrodrig/kzero:v0.9.0`** with **InClusterConfig** fallback when **`run.kubeconfig`** is empty ([kzero v0.8.0+](https://github.com/hrodrig/kzero/releases/tag/v0.8.0)). |
| **Pipeline shape** | Smoke uses **`deployment` / `statefulset`** scale only. **Native infra probe** (Helm SDK + optional **`pvc`**) — see [run/examples/infra-probe/](../examples/infra-probe/README.md). |
| **RBAC** | The Job **ServiceAccount** must be allowed to **get/patch** workloads in **every namespace referenced in YAML**, not only the Job namespace. |

## Job namespace vs pipeline namespaces

- **`kzero-system`** — where the **Job** and **ServiceAccount** run (this example).
- **`kzero-smoke-a`**, **`kzero-smoke-b`** — where the **synthetic Deployments** live; step refs use **`deployment.<ns>/app`**.
- **`Kubernetes target:`** prints the Pod service-account namespace (or kubeconfig context namespace) for **audit** — it is **not** the scope of pipeline mutations. Each step uses the namespace from its compact ref.

For production pilots (many namespaces), start from the **ClusterRole** in **`manifests/02-rbac.yaml`** only in lab clusters; prefer **Role + RoleBinding per target namespace** and derive rules from your pipeline YAML.

## Layout

| Path | Purpose |
|------|---------|
| **`kzero-smoke.sample.yml`** | Editable pipeline config (scale-only, two namespaces). |
| **`manifests/00-namespace.yaml`** | **`kzero-system`** runner namespace. |
| **`manifests/01-smoke-workloads.yaml`** | Demo Deployments in **`kzero-smoke-a`** and **`kzero-smoke-b`**. |
| **`manifests/02-rbac.yaml`** | **ServiceAccount**, **ClusterRole**, **ClusterRoleBinding**. |
| **`manifests/03-configmap.yaml`** | **`kzero.yaml`** mounted at **`/config/kzero.yaml`**. |
| **`manifests/job-analyze.yaml`** | Safe plan-only Job. |
| **`manifests/job-down.yaml`** | Live scale-to-zero Job. |
| **`manifests/job-up.yaml`** | Live scale-up + **`wait_for_ready`** Job. |

After editing **`kzero-smoke.sample.yml`**, refresh the ConfigMap:

```bash
kubectl create configmap kzero-smoke \
  --from-file=kzero.yaml=run/in-cluster/kzero-smoke.sample.yml \
  -n kzero-system \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Quick smoke (kind or any cluster)

From the **kzero-selfhosted** repository root:

```bash
# 1) Install base objects (namespace, RBAC, workloads, config)
kubectl apply -f run/in-cluster/manifests/00-namespace.yaml
kubectl apply -f run/in-cluster/manifests/01-smoke-workloads.yaml
kubectl apply -f run/in-cluster/manifests/02-rbac.yaml
kubectl apply -f run/in-cluster/manifests/03-configmap.yaml

kubectl rollout status deployment/app -n kzero-smoke-a --timeout=120s
kubectl rollout status deployment/app -n kzero-smoke-b --timeout=120s

# 2) Plan (non-mutating)
kubectl delete job kzero-analyze -n kzero-system --ignore-not-found
kubectl apply -f run/in-cluster/manifests/job-analyze.yaml
kubectl logs -n kzero-system job/kzero-analyze -f
kubectl wait -n kzero-system --for=condition=complete job/kzero-analyze --timeout=120s

# 3) Live down → up
kubectl delete job kzero-down kzero-up -n kzero-system --ignore-not-found
kubectl apply -f run/in-cluster/manifests/job-down.yaml
kubectl wait -n kzero-system --for=condition=complete job/kzero-down --timeout=300s
kubectl logs -n kzero-system job/kzero-down

kubectl apply -f run/in-cluster/manifests/job-up.yaml
kubectl wait -n kzero-system --for=condition=complete job/kzero-up --timeout=300s
kubectl logs -n kzero-system job/kzero-up

kubectl get deploy -n kzero-smoke-a app -o jsonpath='{.spec.replicas}{"\n"}'
kubectl get deploy -n kzero-smoke-b app -o jsonpath='{.spec.replicas}{"\n"}'
```

Expected: both Deployments return to **`1`** replica after **`kzero-up`**.

## Automated kind smoke

From the repository root (requires **Docker**, **kind**, **kubectl** — no host **kzero** binary):

```bash
make test-kind-in-cluster
```

Build from a local **[kzero](https://github.com/hrodrig/kzero)** clone when testing unreleased changes:

```bash
export KZERO_IN_CLUSTER_BUILD=1
export KZERO_REPO=/path/to/kzero
export KZERO_IN_CLUSTER_IMAGE=kzero-in-cluster:local
make test-kind-in-cluster
```

Details: [`testing/kind/in-cluster/README.md`](../../testing/kind/in-cluster/README.md).

**`manifests/02-rbac.yaml`** grants **cluster-wide** **`deployments`** / **`statefulsets`** **get/list/watch/patch/update**. That matches multi-namespace pipelines but is broad.

| Pattern | When |
|---------|------|
| **ClusterRole** (this smoke) | Lab, kind, short-lived pilots with many namespaces. |
| **Role per namespace** | Production: one **Role** + **RoleBinding** per namespace listed in **`pipelines.*`**. |
| **Helm / PVC / exec** | **`manifests/02-rbac.yaml`** includes rules for native **`release.*`** (Helm SDK), **`pvc`**, and **`exec`** in lab clusters — tighten to Role-per-namespace in production. |

## Wiring your own pipeline

1. Copy **`kzero-smoke.sample.yml`** and list every **`deployment.*` / `statefulset.*` / `release.*`** ref you need.
2. Set **`run.execution: native`**, leave **`run.kubeconfig`** empty, **`run.mode: live`** for mutating Jobs.
3. Update **RBAC** for every namespace in those refs (and Helm secrets if using releases).
4. Mount config via **ConfigMap** or **Secret**; keep the Job in a dedicated namespace (e.g. **`kzero-system`**).
5. Use **`job-analyze.yaml`** before first live **`down`** in a new environment.

**PlatformOperations** (separate track): an orchestrator can **`kubectl apply`** these Jobs or wrap the same image/args — this repo only ships reference manifests.

## Related

- **Host kind e2e** (kzero on the workstation, not in-cluster): [`testing/kind/README.md`](../../testing/kind/README.md)
- **Schema contract**: [kzero SPECIFICATIONS](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md)

---

[↑ Back to run README](../README.md)
