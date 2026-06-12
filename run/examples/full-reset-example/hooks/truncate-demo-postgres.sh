#!/bin/sh
# Truncate public.demo_scratch in demo-postgresql before Helm teardown.
# Bitnami secret: demo-postgresql / keys postgres-password (superuser postgres).
set -euo pipefail

ns="${KZERO_STEP_NAMESPACE:-kzero-demo}"
secret="demo-postgresql"
pod="demo-postgresql-0"

pass="$(kubectl get secret "$secret" -n "$ns" -o jsonpath='{.data.postgres-password}' | base64 -d)"

kubectl get pod "$pod" -n "$ns" >/dev/null

kubectl exec -i "$pod" -n "$ns" -- \
  env PGPASSWORD="$pass" psql -U postgres -d demo -v ON_ERROR_STOP=1 -c \
  "CREATE TABLE IF NOT EXISTS public.demo_scratch (
     id         bigserial primary key,
     note       text not null default '',
     created_at timestamptz not null default now()
   );
   TRUNCATE public.demo_scratch RESTART IDENTITY;"

echo "truncate-demo-postgres: demo_scratch truncated"
