# Local Kubernetes e2e (kind + kzero)

This suite spins up a **kind** cluster, applies **synthetic workloads** in namespace **`kzero-e2e`** (nginx **web**, **counter** (Postgres-backed lab UI), **Redis**, **RabbitMQ**, **Postgres**, nginx **StatefulSet** with PVC, lightweight **obs** **Deployment**), then runs **kzero** from your machine — a **typical scale-down / scale-up** path across mixed workload types.

**kzero** is **not** run inside the cluster: the script uses **`kubectl`** on your **`PATH`** (same context as **`kind create cluster`**) and the **kzero** binary on the host (`KZERO_BIN`, default **`kzero`**).

## End-to-end phases (full run)

When **`KZERO_KIND_E2E_KZERO=1`** (default for **`make test-kind-e2e`**), **`testing/scripts/kzero-kind-e2e.sh`** runs:

1. **Initialize:** kind cluster, **Docker** build of **`kzero-e2e-counter:e2e`**, **`kind load`**, apply manifests, wait for rollouts. Assert the **UI** (**`GET /`**, parse **`data-e2e-count`**) is **0**, then three **`POST /increment`** form submits (same as clicking **Increment**; **`curl -L`** follows the **303** to **`/`**). Assert counts **1 → 2 → 3**. (Browser: **`kubectl port-forward -n kzero-e2e svc/counter 8080:8080`** → **http://127.0.0.1:8080/**.)
2. **kzero reset:** **`kzero analyze`** (plan, **`Run execution:`**, **Cluster validation** with **OK** for lab workloads; **stderr** may show **Deferred** warnings), **`kzero down`** (dry-run then live), **`kzero up`**. Live config uses **`run.execution: native`**. Postgres **pre-down** hook truncates **`public.e2e_scratch`** before scale-to-zero.
3. **Validate:** after rollouts, **`GET /`** again; **`data-e2e-count`** must be **0**.
4. **Teardown:** on script exit, **`kind delete cluster`** (unless **`KZERO_KIND_NO_CLEANUP`** is set).

## Targets

| Make target | What it does |
|-------------|----------------|
| **`make test-kind-workloads`** | kind + **`kzero-e2e-workloads.yaml`** + rollout waits only (**no** kzero binary required); still **builds/loads** the counter image |
| **`make test-kind-e2e`** | Same + **Phases 1–4** above (**needs** kzero on PATH or **`KZERO_BIN`**) |

```bash
make test-kind-workloads   # cluster + workloads only
make test-kind-e2e         # full kzero exercise (needs kzero on PATH or KZERO_BIN)
```

## Prerequisites

- **Docker**, **kind**, **kubectl** on `PATH`
- **`kzero`** **v0.5.3+** installed for **`make test-kind-e2e`** ([releases](https://github.com/hrodrig/kzero/releases/tag/v0.5.3)) or set **`KZERO_BIN`** to the binary path

## Environment (optional)

| Variable | Purpose |
|----------|---------|
| **`KZERO_KIND_E2E_CLUSTER`** | kind cluster name (default **`kzero-kind-e2e`**) |
| **`KZERO_KIND_ROLLOUT_TIMEOUT`** | **`kubectl rollout status --timeout`** (default **`300s`** — Postgres/RabbitMQ images can be slow on first pull) |
| **`KZERO_KIND_NO_CLEANUP`** | If non-empty, **do not** delete the kind cluster after the run |
| **`KZERO_KIND_E2E_KZERO`** | Set to **`0`** for workloads-only (same as **`make test-kind-workloads`**) |
| **`KZERO_BIN`** | Path to **kzero** (default **`kzero`**) |
| **`KZERO_E2E_COUNTER_IMAGE`** | Docker tag for the lab counter image (default **`kzero-e2e-counter:e2e`**) |
| **`E2E_CURL_IMG`** | Image for ephemeral **`kubectl run … curl`** pods (default **`curlimages/curl:8.5.0`**) |

## Files

| File | Purpose |
|------|---------|
| **`kzero-e2e-workloads.yaml`** | Namespace **`kzero-e2e`**: **Deployments** `web` (×2), **`counter`** (lab HTTP + Postgres), `redis`, `rabbit` (RabbitMQ), `postgres` (emptyDir), **`obs`** (pause, ×1); **StatefulSet** `cache` (nginx + PVC); **Services** for Postgres/Redis/Rabbit/**counter** |
| **`kzero-e2e.yaml`** | **kzero** config: **`live`** pipelines matching those objects |
| **`kzero-e2e-dry-run.yaml`** | Same pipelines, **`run.mode: dry-run`** — used for **`kzero down`** plan before live |
| **`counter/`** | **Go** HTTP app + **Dockerfile** for **`kzero-e2e-counter:e2e`** (built by the e2e script) |
| **`scripts/pg-wipe-e2e.sh`** | **`pre:`** hook on **`deployment.kzero-e2e/postgres`** in the **down** pipeline: **`TRUNCATE public.e2e_scratch`** (and **`CREATE TABLE IF NOT EXISTS`**) via **`kubectl exec`** before scaling Postgres to **0**. Runs on the **host** next to **kzero**; uses **`KZERO_STEP_NAMESPACE`** when set. In **`dry-run`**, **kzero** only logs the planned hook path — it does **not** execute the script or touch the cluster. |

**Hook paths:** **kzero** resolves **`pre:`** / **`post:`** relative to the process working directory (same as **`make test-kind-e2e`**, which runs from the repo root). If you invoke **`kzero down`** by hand, run it from this repository root so **`./testing/kind/scripts/pg-wipe-e2e.sh`** exists.

If you change workload names or namespaces, update **both** YAML configs and the verification loop in **`../scripts/kzero-kind-e2e.sh`**.

## Manual follow-up

After a failed run with **`KZERO_KIND_NO_CLEANUP=1`**:

```bash
kubectl config use-context kind-kzero-kind-e2e   # if default cluster name
kubectl get pods -n kzero-e2e
```

← [Back to testing README](../README.md)
