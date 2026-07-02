# Transcript: `./run-kzero --live reset` — platform-reset (anonymized)

**Date:** 2026-07-01  
**Exit code:** 0  
**Duration:** 9m 45s  
**Cluster slug (log name):** `platform-lab-cluster`  
**Full log (fixture):** [../../examples/platform-reset/fixtures/kzero-reset-platform-lab-cluster-20260701-180311.log.anonymized](../../examples/platform-reset/fixtures/kzero-reset-platform-lab-cluster-20260701-180311.log.anonymized)

Validated on a **lab** cluster (namespace **`platform`**). **`infra_probe`** disabled. Notify disabled.

Generic workload names only (e.g. **`worker-alpha`**, **`jobstore-beta`**, **`orchestrator`**). Helm SDK + public Bitnami OCI charts in the committed **`helm/`** workspace.

```
Type YES to continue against that cluster: YES

2026/07/01 18:03:12: kzero - [INF] - [live] scale statefulset.platform/worker-alpha-slave -> 0 replicas
…
2026/07/01 18:04:18: kzero - [INF] - [live] hook pipeline-down-22: ./hooks/truncate-job-queue.sh
truncate-job-queue: TRUNCATE job_queue ok
2026/07/01 18:04:24: kzero - [INF] - [live] helm sdk uninstall platform/jobstore-notifier (--wait --ignore-not-found)
…
2026/07/01 18:06:46: kzero - [INF] - [live] delete pvc platform/data-platform-postgresql-0 (background propagation, ignore-not-found)
2026/07/01 18:06:50: kzero - [INF] - [live] helm sdk upgrade --install platform/postgresql (… bitnamicharts/postgresql …)
…
2026/07/01 18:09:42: kzero - [INF] - [live] still installing release release.platform/jobstore-notifier (elapsed 30s)
2026/07/01 18:11:17: kzero - [INF] - [live] wait rollout deployment.platform/orchestrator (timeout 15m0s)
2026/07/01 18:11:47: kzero - [INF] - [live] still waiting rollout deployment.platform/orchestrator (elapsed 30s)
…
2026/07/01 18:12:31: kzero - [INF] - [live] scale statefulset.platform/worker-gamma-slave -> 4 replicas
2026/07/01 18:12:56: kzero - [INF] - rollout-restart-notifier: deployment and statefulset restarted
2026/07/01 18:12:56: kzero - [INF] - kzero reset finished in 9m45.156s
```

**Observations useful for operators:**

- Throttled **still installing** / **still waiting rollout** lines during long Helm and **`wait_for_ready`** steps  
- **`wait-master-ready`** / **`wait-dashboard-ready`** gate slave scale-up order  
- Log filename pattern: **`kzero-reset-platform-lab-cluster-20260701-180311.log`** (cluster slug from **`kzero target --output slug`**)

Post-reset: run **`./run-kzero analyze`** and confirm down/up step counts match your cluster inventory.
