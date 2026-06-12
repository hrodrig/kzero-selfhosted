# Transcript: `./run-kzero --live probe` (anonymized)

**Date:** 2026-06-12  
**Exit code:** 0  
**Duration:** ~3m 20s

```
2026/06/12 10:00:00: kzero - [INF] - helm sdk upgrade --install platform/kzero-probe-redis
2026/06/12 10:01:45: kzero - [INF] - check pvc_bound: redis-data-kzero-probe-redis-master-0 Bound
2026/06/12 10:02:10: kzero - [INF] - check release_ready: platform/kzero-probe-redis ready
2026/06/12 10:03:05: kzero - [INF] - helm sdk uninstall platform/kzero-probe-redis (--wait)
2026/06/12 10:03:18: kzero - [INF] - infra_probe succeeded
```

Optional Slack: **`kzero completed`** with footer **`kzero v0.7.3`**.
