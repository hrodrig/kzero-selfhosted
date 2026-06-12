# Transcript: `./run-kzero up` (dry-run, anonymized)

**Date:** 2026-06-12  
**Exit code:** 0  
**Duration:** ~22 s

```
2026/06/12 09:10:00: kzero - [INF] - [dry-run] helm sdk upgrade --install platform/postgresql (manifest: …/helm/postgresql.yaml)
2026/06/12 09:10:01: kzero - [INF] - [dry-run] helm sdk upgrade --install platform/rabbitmq
2026/06/12 09:10:02: kzero - [INF] - [dry-run] helm sdk upgrade --install platform/jobstore-worker
2026/06/12 09:10:03: kzero - [INF] - [dry-run] helm sdk upgrade --install platform/jobstore-api (post: wait-helm-release-ready.sh)
2026/06/12 09:10:04: kzero - [INF] - [dry-run] helm sdk upgrade --install platform/redis-cache
2026/06/12 09:10:05: kzero - [INF] - [dry-run] native scale deployment.platform/gateway -> 1 replicas (server-side dry-run ok)
2026/06/12 09:10:06: kzero - [INF] - [dry-run] native scale deployment.platform/notifier -> 1 replicas (server-side dry-run ok)
2026/06/12 09:10:07: kzero - [INF] - [dry-run] native scale deployment.platform/api -> 1 replicas (wait_for_ready)
2026/06/12 09:10:08: kzero - [INF] - [dry-run] native scale deployment.platform/worker -> 1 replicas (server-side dry-run ok)
2026/06/12 09:10:09: kzero - [INF] - [dry-run] native scale statefulset.platform/worker-slave -> 3 replicas (pre: wait-master-ready.sh)
2026/06/12 09:10:09: kzero - [INF] - [dry-run] custom hook ./hooks/rollout-restart-notifier.sh (skipped in dry-run)
2026/06/12 09:10:10: kzero - [INF] - [dry-run] native scale deployment.platform/frontend -> 3 replicas (server-side dry-run ok)
2026/06/12 09:10:10: kzero - [INF] - up pipeline completed in 22.1s
```
