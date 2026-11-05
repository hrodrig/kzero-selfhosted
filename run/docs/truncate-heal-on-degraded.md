# Truncate with heal (degraded cluster)

**Use case:** a **`down`** / **`reset`** step must **`TRUNCATE`** (or otherwise `kubectl exec`) into a database pod that **must remain up**. On a **degraded** cluster the pod or named container may be missing, not Ready, or reject `exec` (`container not found`, `unable to upgrade connection`). Fail-fast without recovery aborts the whole pipeline (and **`reset`** skips **`up`**).

**Policy:** do **not** skip the step. **Heal** the StatefulSet (ensure replicas ≥ 1, delete the pod, wait Ready), then **retry** the exec a bounded number of times. Treat SQL/auth failures as fatal (no restart loop).

## Reference hook

Copy or point at:

[run/examples/hooks/truncate-with-heal.sh](../examples/hooks/truncate-with-heal.sh)

```yaml
pipelines:
  down:
    # … scale app workloads that must drain first …
    - custom: ./hooks/truncate-with-heal.sh
    # … continue uninstall / PVC wipe; state-store may stay or be torn down later …
```

Defaults are anonymized lab names (`platform` / `state-store` / `platform.job_queue`). Override with env:

| Variable | Default | Role |
|----------|---------|------|
| `KZERO_STEP_NAMESPACE` | `platform` | Namespace (set by kzero when the step has a namespace) |
| `STATE_STORE_STS` | `state-store` | StatefulSet name |
| `STATE_STORE_POD` | `state-store-0` | Pod name |
| `STATE_STORE_SECRET` | `state-store` | Secret for password fallback |
| `STATE_STORE_CONTAINER` | `postgresql` | Container name for `exec` |
| `TRUNCATE_TABLE` | `platform.job_queue` | `schema.table` for `TRUNCATE` |
| `TRUNCATE_ATTEMPTS` | `5` | Heal/retry budget |
| `TRUNCATE_WAIT_TIMEOUT` | `180s` | `kubectl wait` / delete timeout |
| `PG_USER` / `PG_PASSWORD` / `PG_DATABASE` | (secret / defaults) | Credentials |

Interpreter: **`/bin/sh`** (kzero default). Script uses **`set -eu`** only — no **`pipefail`** (often unavailable under dash).

## Related

- Simpler truncate (no heal): [platform-reset/hooks/truncate-job-queue.sh](../examples/platform-reset/hooks/truncate-job-queue.sh)
- Pipeline order when truncating **before** scale-to-zero: [kzero docs — pipeline order](https://github.com/hrodrig/kzero/blob/main/docs/examples/pipeline-order-and-integrity.md)
- Optional **`state-store`** Helm assets: [platform-reset/helm/state-store.yaml](../examples/platform-reset/helm/state-store.yaml)
