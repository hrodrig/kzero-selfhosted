# Platform reset example — large lab profile

Anonymized **real-cluster** maintenance profile derived from a QA live reset (~**9m45s**). Namespace **`platform`**. Generic workload names (no product-specific identifiers). **Helm SDK** manifests under **`helm/`** use public Bitnami OCI charts.

**Not production.** Assumes Deployments/StatefulSets already exist in **`platform`** (installed by your platform chart or a prior bootstrap). This profile scales apps down, truncates a job queue, reinstalls infra Helm releases, wipes PVCs, and scales back up.

**Requires [kzero v0.8.0+](https://github.com/hrodrig/kzero/releases/tag/v0.8.0)** (**v0.8.1** recommended; **`kzero target --output slug`** for log filenames), **`kubectl`**, **`helm`**, lab kubeconfig, StorageClass.

Compare with **[full-reset-example](../full-reset-example/)** (self-contained **`kzero-demo`**, WordPress bootstrap, smaller step count).

---

## Quick start

```bash
cd run/examples/platform-reset
cp env.example .env          # edit KUBECONFIG if needed
chmod +x run-kzero hooks/*.sh

./run-kzero analyze
./run-kzero down             # dry-run (default)
./run-kzero --live reset     # lab only — type YES
```

Logs: **`.logs/kzero-<cmd>-<cluster-slug>-<timestamp>.log`**

Anonymized success fixture: **[fixtures/kzero-reset-platform-lab-cluster-20260701-180311.log.anonymized](fixtures/kzero-reset-platform-lab-cluster-20260701-180311.log.anonymized)**  
Transcript summary: **[run/docs/transcripts/reset-live-transcript-platform.anonymized.md](../../docs/transcripts/reset-live-transcript-platform.anonymized.md)**

---

## Layout

| Path | Role |
|------|------|
| `kzero-platform-reset.sample.yml` | Down/up pipelines (~29 up steps, hooks, Helm releases) |
| `env.example` | Copy to `.env` (not committed) |
| `run-kzero` | Wrapper: YES gate, cluster slug in log name, tee to `.logs/` |
| `hooks/` | `truncate-job-queue`, `wait-master-ready`, `wait-dashboard-ready`, `wait-helm-release-ready`, `rollout-restart-notifier` |
| `helm/` | Chart manifests + values (native **`run.execution`**) |

---

## Helm workspace (`helm/`)

**In default reset pipeline:**

| Release | Chart | Notes |
|---------|-------|--------|
| `postgresql` | Bitnami PostgreSQL | Main DB; truncate hook target |
| `rabbitmq` | Bitnami RabbitMQ | Message broker |
| `redis-cache` | Bitnami Redis | LRU cache (`wait: true` on up) |
| `jobstore-alpha` … `jobstore-notifier` | Bitnami PostgreSQL ×5 | Per-service job stores |
| `kzero-probe-redis` | Bitnami Redis | **`infra_probe`** only (disabled by default) |

**Optional (not in sample YAML — copy patterns for extended platforms):**

| Release | Files |
|---------|--------|
| `state-store` | `state-store.yaml`, `state-store-values.yaml` |
| `mongodb` | `mongodb.yaml`, `mongodb-values.yaml` |

Private OCI mirrors: set **`helm.registries[]`** in YAML and **`HELM_REGISTRY_*`** in `.env` (see `env.example` comments).

---

## Pipeline highlights

- **Down:** scale ~21 workloads → truncate → Helm uninstall (8 releases) → delete 8 PVCs  
- **Up:** Helm install infra → scale core services → **`wait_for_ready`** on orchestrator → **`pre`** hooks (`wait-master-ready` / `wait-dashboard-ready`) before slave StatefulSets (×4) → rollout restart notifier → frontend ×3  
- **`infra_probe`:** disabled; enable and add probe assets to use before live **`reset`**

---

## Do not commit

- `.env`, `.logs/`, `.probe-cache/`

---

## Related docs

- [full-reset-validation.md](../../docs/full-reset-validation.md) — smaller lab runbook  
- [pipeline-network-loss.md](https://github.com/hrodrig/kzero/blob/develop/docs/examples/pipeline-network-loss.md) — bastion log + watchdog patterns  
- [kzero SPECIFICATIONS](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md)
