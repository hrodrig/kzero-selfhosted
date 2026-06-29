# Full reset example — real cluster lab

Self-contained **maintenance reset** demo on **your own Kubernetes cluster** (not kind): namespace **`kzero-demo`**, public images only, Bitnami Helm charts from **Docker Hub OCI**, WordPress + MySQL + PostgreSQL + Redis + RabbitMQ.

**Requires [kzero v0.8.0+](https://github.com/hrodrig/kzero/releases/tag/v0.8.0)** (**v0.8.1** recommended), **`kubectl`**, **`helm`**, a **lab/staging kubeconfig**, and a **StorageClass** for PVCs. **Do not run against production.**

## Quick start

```bash
cd run/examples/full-reset-example
cp env.example .env          # optional — kubectl uses ~/.kube/config if KUBECONFIG unset

chmod +x install-demo.sh uninstall-demo.sh run-kzero hooks/*.sh

./install-demo.sh          # once: Helm infra + WordPress in kzero-demo
./run-kzero analyze
./run-kzero down           # dry-run (default)
./run-kzero probe
./run-kzero --live reset   # live — type YES; mutates kzero-demo only
```

Remove everything: **`./uninstall-demo.sh`** (type **`DELETE`**).

## What gets installed

| Workload | Type | Image / chart |
|----------|------|----------------|
| **wordpress** | Deployment | `wordpress:6.7.2-apache` → **demo-mysql** |
| **demo-mysql** | Helm (Bitnami) | WordPress database |
| **demo-postgresql** | Helm | Side infra; **`truncate-demo-postgres.sh`** wipes **`demo_scratch`** on reset |
| **demo-redis** | Helm | Cache (standalone) |
| **demo-rabbitmq** | Helm | Message broker |

**`infra_probe`** installs ephemeral **`kzero-probe-redis`** before **`reset`** (Helm SDK, same Bitnami Redis chart).

## Reset pipeline (kzero)

**Down (10 steps):** scale WordPress → 0 → truncate Postgres → Helm uninstall (mysql, redis, rabbitmq, postgresql) → delete 4 PVCs.

**Up (5 steps):** Helm install infra (postgres → rabbit → redis → mysql) → scale WordPress → 1 with **`wait_for_ready`**.

**Live runs:** profile enables **`run.api_watchdog`** (trips after **5m** cumulative API loss; dispatches **`pipeline.stalled`** when notify is configured). See [kzero pipeline-network-loss](https://github.com/hrodrig/kzero/blob/main/docs/examples/pipeline-network-loss.md).

## Layout

| Path | Purpose |
|------|---------|
| **`bootstrap/`** | Namespace, WordPress Deployment/Service/Secret |
| **`helm/`** | Helm SDK manifests + values (public **`oci://registry-1.docker.io/bitnamicharts/*`**) |
| **`hooks/`** | **`truncate-demo-postgres.sh`**, **`wait-helm-release-ready.sh`** |
| **`install-demo.sh`** | Bootstrap on real cluster (no kzero required) |
| **`uninstall-demo.sh`** | Delete namespace |
| **`run-kzero`** | Wrapper with **`--live`** / **`YES`** gate |
| **`kzero-full-reset.sample.yml`** | kzero profile |

## Cluster requirements

- **CPU/RAM:** ~2–4 cores and 4–8 Gi free (first pull of Bitnami images is slow).
- **Storage:** default **StorageClass** for PVCs.
- **Network:** egress to **Docker Hub** / **registry-1.docker.io** (Helm OCI).
- **RBAC:** create/delete resources in **`kzero-demo`** (Deployments, PVCs, Helm releases).

## Docs

- **[Validation runbook](../../docs/full-reset-validation.md)**
- **[Notifications](../../docs/notifications-full-reset.md)**
- **[kzero SPECIFICATIONS](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md)**

← [Back to run/examples](../README.md)
