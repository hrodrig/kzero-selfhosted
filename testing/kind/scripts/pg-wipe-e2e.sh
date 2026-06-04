#!/bin/sh
# pre-down hook for deployment.kzero-e2e/postgres — wipe lab data before scaling Postgres to 0.
# Runs on the host (same as kzero); requires kubectl and a running postgres pod.
# Env from kzero: KZERO_STEP_NAMESPACE, KZERO_STEP_NAME (see internal/engine/live_runner.go).
set -eu

ns="${KZERO_STEP_NAMESPACE:-kzero-e2e}"

echo "pg-wipe-e2e: truncating public.e2e_scratch in namespace ${ns} (pre-down postgres)"

kubectl exec -n "$ns" "deployment/postgres" -- \
  psql -U app -d app -v ON_ERROR_STOP=1 -c \
  "CREATE TABLE IF NOT EXISTS public.e2e_scratch (
     id         bigserial primary key,
     note       text not null default '',
     created_at timestamptz not null default now()
   );
   TRUNCATE public.e2e_scratch RESTART IDENTITY;"

echo "pg-wipe-e2e: done."
