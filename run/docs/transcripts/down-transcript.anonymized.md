# Transcript: `./run-kzero down` (dry-run, anonymized)

**Date:** 2026-06-12  
**Exit code:** 0  
**Duration:** ~18 s

```
⚠️  dry-run mode: the cluster is not changed (only [dry-run] lines in the log).

2026/06/12 09:05:00: kzero - [INF] - [dry-run] native scale statefulset.platform/worker-slave -> 0 replicas (server-side dry-run ok)
2026/06/12 09:05:01: kzero - [INF] - [dry-run] native scale deployment.platform/worker -> 0 replicas (server-side dry-run ok)
2026/06/12 09:05:02: kzero - [INF] - [dry-run] native scale deployment.platform/api -> 0 replicas (server-side dry-run ok)
2026/06/12 09:05:03: kzero - [INF] - [dry-run] native scale deployment.platform/frontend -> 0 replicas (server-side dry-run ok)
2026/06/12 09:05:04: kzero - [INF] - [dry-run] native scale deployment.platform/gateway -> 0 replicas (server-side dry-run ok)
2026/06/12 09:05:05: kzero - [INF] - [dry-run] native scale deployment.platform/notifier -> 0 replicas (server-side dry-run ok)
2026/06/12 09:05:05: kzero - [INF] - [dry-run] custom hook ./hooks/truncate-job-queue.sh (skipped in dry-run)
2026/06/12 09:05:05: kzero - [INF] - [dry-run] helm sdk uninstall platform/jobstore-api (--wait --ignore-not-found)
2026/06/12 09:05:06: kzero - [INF] - [dry-run] helm sdk uninstall platform/jobstore-worker (--wait --ignore-not-found)
2026/06/12 09:05:06: kzero - [INF] - [dry-run] helm sdk uninstall platform/redis-cache (--wait --ignore-not-found)
2026/06/12 09:05:06: kzero - [INF] - [dry-run] helm sdk uninstall platform/rabbitmq (--wait --ignore-not-found)
2026/06/12 09:05:06: kzero - [INF] - [dry-run] helm sdk uninstall platform/postgresql (--wait --ignore-not-found)
2026/06/12 09:05:07: kzero - [INF] - [dry-run] pvc delete platform/data-jobstore-api-0
2026/06/12 09:05:07: kzero - [INF] - [dry-run] pvc delete platform/data-jobstore-worker-0
2026/06/12 09:05:08: kzero - [INF] - [dry-run] pvc delete platform/data-postgres-0
2026/06/12 09:05:08: kzero - [INF] - [dry-run] pvc delete platform/data-rabbitmq-0
2026/06/12 09:05:08: kzero - [INF] - [dry-run] pvc delete platform/redis-data-redis-cache-master-0
2026/06/12 09:05:08: kzero - [INF] - down pipeline completed in 18.2s
```
