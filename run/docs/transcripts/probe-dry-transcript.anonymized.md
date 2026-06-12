# Transcript: `./run-kzero probe` (dry-run, anonymized)

**Date:** 2026-06-12  
**Exit code:** 0

```
2026/06/12 09:15:00: kzero - [INF] - infra_probe: cache miss, running probe pipeline
2026/06/12 09:15:00: kzero - [INF] - [dry-run] helm sdk upgrade --install platform/kzero-probe-redis
2026/06/12 09:15:01: kzero - [INF] - [dry-run] check pvc_bound platform/redis-data-kzero-probe-redis-master-0
2026/06/12 09:15:01: kzero - [INF] - [dry-run] check release_ready platform/kzero-probe-redis
2026/06/12 09:15:01: kzero - [INF] - [dry-run] helm sdk uninstall platform/kzero-probe-redis
2026/06/12 09:15:01: kzero - [INF] - infra_probe succeeded (dry-run)
```
