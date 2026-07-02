#!/bin/sh
# Truncate platform.job_queue on the main PostgreSQL release before infra reinstall.
set -euo pipefail

ns="${KZERO_STEP_NAMESPACE:-platform}"
pod="platform-postgresql-0"
user="${PLATFORM_PG_USER:-demo}"
pass="${PLATFORM_PG_PASSWORD:-demo-pg-pass}"
db="${PLATFORM_PG_DATABASE:-platform}"

kubectl get pod "$pod" -n "$ns" >/dev/null

kubectl exec -i "$pod" -n "$ns" -- \
  env PGPASSWORD="$pass" psql -U "$user" -d "$db" \
  -c "TRUNCATE TABLE platform.job_queue CASCADE;" 2>/dev/null \
  || kubectl exec -i "$pod" -n "$ns" -- \
       env PGPASSWORD="$pass" psql -U "$user" -d "$db" \
       -c "TRUNCATE TABLE job_queue CASCADE;"

echo "truncate-job-queue: TRUNCATE job_queue ok"
