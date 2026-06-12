# Transcript: `./run-kzero analyze` (anonymized)

**Date:** 2026-06-12  
**Exit code:** 0  
**Full log (local):** `.logs/kzero-analyze-20260612-090000.log`

Placeholders: `$EXAMPLE_DIR`, `<API_HOST>`, `$USER`, `<uid>`.

```
ℹ️  Starting full-reset-example at …; run.mode=dry-run
ℹ️  kzero analyze --config $EXAMPLE_DIR/kzero-full-reset.sample.yml (log: ./.logs/kzero-analyze-….log)

2026/06/12 09:00:00: kzero - [INF] - Config: $EXAMPLE_DIR/kzero-full-reset.sample.yml
2026/06/12 09:00:00: kzero - [INF] - Run mode: dry-run
2026/06/12 09:00:00: kzero - [INF] - Client id: ops-automation
2026/06/12 09:00:00: kzero - [INF] - Kubernetes target:
2026/06/12 09:00:00: kzero - [INF] -   context: staging-context
2026/06/12 09:00:00: kzero - [INF] -   cluster: lab-cluster
2026/06/12 09:00:00: kzero - [INF] -   namespace: platform
2026/06/12 09:00:00: kzero - [INF] -   api_server: https://<API_HOST>:6443

2026/06/12 09:00:00: kzero - [INF] - Pipeline steps: down=17 up=12
2026/06/12 09:00:00: kzero - [INF] - [down]
2026/06/12 09:00:00: kzero - [INF] -   0: statefulset.platform/worker-slave
2026/06/12 09:00:00: kzero - [INF] -   1: deployment.platform/worker
2026/06/12 09:00:00: kzero - [INF] -   …
2026/06/12 09:00:00: kzero - [INF] -   6: custom: ./hooks/truncate-job-queue.sh
2026/06/12 09:00:00: kzero - [INF] -   7-11: release.platform/* (helm sdk uninstall)
2026/06/12 09:00:00: kzero - [INF] -   12-16: pvc.platform/* (delete)
2026/06/12 09:00:00: kzero - [INF] - [up]
2026/06/12 09:00:00: kzero - [INF] -   0-4: release.platform/* (helm upgrade --install)
2026/06/12 09:00:00: kzero - [INF] -   5-10: deployment/statefulset scale + hooks
2026/06/12 09:00:00: kzero - [INF] -   11: deployment.platform/frontend (replicas: 3)
2026/06/12 09:00:00: kzero - [INF] - infra_probe: before reset; release kzero-probe-redis
```
