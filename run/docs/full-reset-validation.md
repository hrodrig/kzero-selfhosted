# Full reset validation runbook

Operator checklist for **[full-reset-example](../examples/full-reset-example/)** on a **real lab/staging cluster** (namespace **`kzero-demo`**). **Not kind.** **Not production.**

**Upstream:** [kzero v0.9.0](https://github.com/hrodrig/kzero/releases/tag/v0.9.0)

---

## Prerequisites

| Item | Notes |
|------|--------|
| **Cluster** | Any reachable Kubernetes (k3s, RKE, EKS, GKE, on-prem lab, …) |
| **kzero** | `kzero version` ≥ **0.9.0** on the bastion/host |
| **kubectl** / **helm** | On `PATH`; **`KUBECONFIG`** in **`.env`** |
| **StorageClass** | Default SC for Bitnami PVCs |
| **Egress** | Pull from Docker Hub / `registry-1.docker.io` (Bitnami OCI) |

---

## Bootstrap (once)

From **`run/examples/full-reset-example/`**:

```bash
cp env.example .env   # set KUBECONFIG
./install-demo.sh            # confirm with y/yes
kubectl get pods -n kzero-demo
```

Expect: **`demo-mysql-0`**, **`demo-postgresql-0`**, **`demo-redis-master-0`**, **`demo-rabbitmq-0`**, **`wordpress-*`** Running (may take several minutes on first pull).

Optional smoke: `kubectl port-forward -n kzero-demo svc/wordpress 8080:80` → http://127.0.0.1:8080/

---

## Validation sequence

| Step | Command | Expected |
|------|---------|----------|
| 0 | `./run-kzero analyze` | **down=10**, **up=5**; namespace **kzero-demo** |
| 1 | `./run-kzero down` | Exit **0**; all **`[dry-run]`** |
| 2 | `./run-kzero up` | Exit **0**; all **`[dry-run]`** |
| 3 | `./run-kzero probe` | Exit **0**; probe plan in dry-run |
| 4 | `./run-kzero --live reset` | Type **`YES`**; exit **0** |
| 5 | `./run-kzero analyze` | Same step counts |
| 6 | WordPress reachable again | port-forward or Ingress if configured |

Logs: **`.logs/kzero-<cmd>-<cluster-slug>-*.log`** (slug from `kzero target --output slug`)

---

## Live reset — what changes (kzero-demo only)

1. WordPress scaled to **0**
2. **`truncate-demo-postgres.sh`** — `TRUNCATE public.demo_scratch` in **demo-postgresql-0**
3. Helm uninstall **demo-mysql**, **demo-redis**, **demo-rabbitmq**, **demo-postgresql**
4. PVC delete: **`data-demo-mysql-0`**, **`data-demo-postgresql-0`**, **`data-demo-rabbitmq-0`**, **`redis-data-demo-redis-master-0`**
5. Helm reinstall infra → WordPress **1** replica, **`wait_for_ready`**

**Before reset:** **`infra_probe`** installs **kzero-probe-redis**, checks PVC + release, uninstalls probe chart.

---

## Teardown

```bash
./uninstall-demo.sh   # type DELETE — removes namespace kzero-demo
```

---

## Troubleshooting

| Symptom | Check |
|---------|--------|
| WordPress CrashLoop | **demo-mysql** ready? Secret **`wordpress-db`** matches mysql values |
| Helm OCI pull fail | Network to `registry-1.docker.io`; try `helm pull oci://registry-1.docker.io/bitnamicharts/redis --version 20.6.3` |
| **ImagePullBackOff** `bitnami/*` | Charts default to removed Docker Hub tags — values use **`bitnamilegacy/*`**; upgrade release or `./uninstall-demo.sh` + `./install-demo.sh` |
| Truncate hook fails | Pod **demo-postgresql-0** running; secret **demo-postgresql** |
| PVC stuck Terminating | Finalizers / PV reclaim; delete release first |
| Wrong cluster | **`./run-kzero`** prints **`kzero target`** before live **`YES`** |

---

## Transcripts

Anonymized CLI samples (step counts may predate **kzero-demo** refresh): [transcripts/](transcripts/). Large platform profile: [platform-reset](../examples/platform-reset/) + [reset-live-transcript-platform.anonymized.md](transcripts/reset-live-transcript-platform.anonymized.md).

← [full-reset-example README](../examples/full-reset-example/README.md)
