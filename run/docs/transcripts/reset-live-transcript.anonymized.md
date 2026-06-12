# Transcript: `./run-kzero --live reset` (anonymized)

**Date:** 2026-06-12  
**Exit code:** 0  
**Duration:** 7m 45s  
**Full log (local):** `.logs/kzero-reset-20260612-101530.log`

Validated on a lab cluster (namespace **`platform`**). Slack notify enabled.

```
Type YES to continue against that cluster: YES

2026/06/12 10:15:30: kzero - [INF] - notify: slack started
2026/06/12 10:15:31: kzero - [INF] - infra_probe: running before reset
2026/06/12 10:18:50: kzero - [INF] - infra_probe succeeded
2026/06/12 10:18:51: kzero - [INF] - down pipeline begin
2026/06/12 10:19:05: kzero - [INF] - native scale statefulset.platform/worker-slave -> 0 replicas
…
2026/06/12 10:20:12: kzero - [INF] - custom hook truncate-job-queue.sh
truncate-job-queue: TRUNCATE platform.job_queue ok
2026/06/12 10:20:45: kzero - [INF] - helm sdk uninstall platform/postgresql
2026/06/12 10:21:30: kzero - [INF] - pvc delete platform/data-postgres-0
2026/06/12 10:21:55: kzero - [INF] - down pipeline completed
2026/06/12 10:21:56: kzero - [INF] - up pipeline begin
2026/06/12 10:25:40: kzero - [INF] - helm sdk upgrade --install platform/postgresql
…
2026/06/12 10:22:50: kzero - [INF] - custom hook rollout-restart-notifier.sh
rollout-restart-notifier: deployment and statefulset restarted
2026/06/12 10:23:12: kzero - [INF] - up pipeline completed
2026/06/12 10:23:15: kzero - [INF] - notify: slack completed
2026/06/12 10:23:15: kzero - [INF] - reset finished in 7m45s
```

Post-reset: **`./run-kzero analyze`** exit **0**, **down=17 up=12**.
