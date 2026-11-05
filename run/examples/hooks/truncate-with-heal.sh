#!/bin/sh
# Reference hook: TRUNCATE a table via kubectl exec, healing the StatefulSet when
# the pod/container is unavailable (degraded cluster). Use as a pipelines.down
# custom: step (or step pre) when the database workload must stay up for the
# truncate — do not skip the step; restart/wait until Ready, then retry.
#
# Interpreter: /bin/sh via kzero (default command.shell). No bashisms; no pipefail.
#
# Defaults match the optional platform-reset state-store naming. Override with env
# or KZERO_STEP_NAMESPACE from the pipeline step.
#
# Example (pipelines.down):
#   - custom: ./hooks/truncate-with-heal.sh
#
set -eu

ns="${KZERO_STEP_NAMESPACE:-platform}"
sts="${STATE_STORE_STS:-state-store}"
pod="${STATE_STORE_POD:-state-store-0}"
secret="${STATE_STORE_SECRET:-state-store}"
container="${STATE_STORE_CONTAINER:-postgresql}"
attempts="${TRUNCATE_ATTEMPTS:-5}"
wait_timeout="${TRUNCATE_WAIT_TIMEOUT:-180s}"
# SQL identifier only (schema.table). Override for your lab schema.
table="${TRUNCATE_TABLE:-platform.job_queue}"

# Credentials: prefer env (lab). Optional Bitnami-style secret keys as fallback.
user="${PG_USER:-}"
pass="${PG_PASSWORD:-}"
db="${PG_DATABASE:-}"

decode_secret() {
  kubectl get secret "$secret" -n "$ns" -o "jsonpath={.data.$1}" 2>/dev/null | base64 -d
}

if [ -z "$user" ]; then
  user="$(decode_secret 'postgres-user')"
fi
if [ -z "$user" ]; then
  user="postgres"
fi
if [ -z "$pass" ]; then
  pass="$(decode_secret 'postgres-password')"
fi
if [ -z "$db" ]; then
  db="$(decode_secret 'database-name')"
fi
if [ -z "$db" ]; then
  db="platform"
fi

if [ -z "$pass" ]; then
  echo "truncate-with-heal: set PG_PASSWORD or secret ${secret} key postgres-password" >&2
  exit 1
fi

is_unavailable() {
  grep -qiE \
    'container not found|Unable to connect to the server|unable to upgrade connection|cannot exec|error.*not found|is not ready|container.*(not running|is in)|pod .* not found|Error from server \(NotFound\)'
}

ensure_replicas() {
  kubectl scale "statefulset/${sts}" -n "$ns" --replicas=1
}

ensure_ready() {
  kubectl wait --for=condition=Ready "pod/${pod}" -n "$ns" --timeout="$wait_timeout"
}

heal() {
  echo "truncate-with-heal: healing statefulset/${sts} pod/${pod}" >&2
  ensure_replicas
  kubectl delete pod "$pod" -n "$ns" --ignore-not-found=true --wait=true --timeout="$wait_timeout" || true
  ensure_ready
}

run_truncate() {
  kubectl exec -i "$pod" -n "$ns" -c "$container" -- \
    env PGPASSWORD="$pass" psql -U "$user" -h 127.0.0.1 -d "$db" \
    -c "TRUNCATE TABLE ${table} CASCADE;"
}

i=1
while [ "$i" -le "$attempts" ]; do
  echo "truncate-with-heal: attempt ${i}/${attempts}" >&2

  if ! ensure_replicas; then
    echo "truncate-with-heal: scale statefulset/${sts} failed" >&2
    exit 1
  fi

  if ! ensure_ready; then
    echo "truncate-with-heal: pod not Ready; healing" >&2
    heal || true
  fi

  err="$(mktemp)"
  if run_truncate 2>"$err"; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "truncate-with-heal: TRUNCATE ${table} ok"
    exit 0
  fi

  cat "$err" >&2 || true
  if is_unavailable <"$err"; then
    rm -f "$err"
    echo "truncate-with-heal: target unavailable; healing and retrying" >&2
    heal || true
    i=$((i + 1))
    continue
  fi

  rm -f "$err"
  echo "truncate-with-heal: non-recoverable exec failure" >&2
  exit 1
done

echo "truncate-with-heal: exhausted ${attempts} attempts" >&2
exit 1
