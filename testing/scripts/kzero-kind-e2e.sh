#!/usr/bin/env bash
# kind + synthetic workloads + optional kzero live down/up (see testing/kind/README.md).
# Requires: docker, kind, kubectl. Requires kzero when KZERO_KIND_E2E_KZERO=1 (default).
# Optional: KZERO_KIND_E2E_CLUSTER (default kzero-kind-e2e), KZERO_KIND_NO_CLEANUP, KZERO_KIND_ROLLOUT_TIMEOUT
# Optional: E2E_CURL_IMG (default curlimages/curl:8.5.0) — ephemeral pods exercise the counter UI (GET /, POST /increment).
set -euo pipefail

CLUSTER_NAME="${KZERO_KIND_E2E_CLUSTER:-kzero-kind-e2e}"
ROLLOUT_TIMEOUT="${KZERO_KIND_ROLLOUT_TIMEOUT:-300s}"
KZERO_BIN="${KZERO_BIN:-kzero}"
COUNTER_IMAGE="${KZERO_E2E_COUNTER_IMAGE:-kzero-e2e-counter:e2e}"
E2E_CURL_IMG="${E2E_CURL_IMG:-curlimages/curl:8.5.0}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORKLOADS="$REPO_ROOT/testing/kind/kzero-e2e-workloads.yaml"
CFG_LIVE="$REPO_ROOT/testing/kind/kzero-e2e.yaml"
CFG_DRY="$REPO_ROOT/testing/kind/kzero-e2e-dry-run.yaml"
NS="kzero-e2e"

# Resources to wait after apply and after kzero up (Postgres before counter).
ROLLOUT_TARGETS=(
  "deployment/postgres"
  "deployment/counter"
  "deployment/web"
  "deployment/redis"
  "deployment/rabbit"
  "statefulset/cache"
  "deployment/obs"
)

# For replica==0 checks after kzero down (short kubectl types).
REPLICA_CHECK=(
  "deploy/web"
  "deploy/counter"
  "deploy/redis"
  "deploy/rabbit"
  "deploy/postgres"
  "sts/cache"
  "deploy/obs"
)

dump_diagnostics() {
  echo ""
  echo "========== diagnostics (namespace $NS) =========="
  kubectl get pods,deploy,sts,ds -n "$NS" -o wide 2>/dev/null || true
  echo ""
  kubectl get events -n "$NS" --sort-by='.lastTimestamp' 2>/dev/null | tail -50 || true
  echo "========== end diagnostics =========="
  echo ""
}

cleanup() {
  if [[ -n "${KZERO_KIND_NO_CLEANUP:-}" ]]; then
    echo "KZERO_KIND_NO_CLEANUP is set; keeping kind cluster: $CLUSTER_NAME"
    echo "  kubectl config use-context kind-$CLUSTER_NAME"
    return 0
  fi
  echo "Phase 4: destroying kind cluster --name $CLUSTER_NAME"
  kind delete cluster --name "$CLUSTER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

for cmd in docker kind kubectl; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "error: '$cmd' not found on PATH"
    exit 1
  }
done

test -f "$WORKLOADS" || {
  echo "error: missing $WORKLOADS"
  exit 1
}
test -f "$CFG_LIVE" || {
  echo "error: missing $CFG_LIVE"
  exit 1
}
test -f "$CFG_DRY" || {
  echo "error: missing $CFG_DRY"
  exit 1
}

echo "Creating kind cluster: $CLUSTER_NAME"
kind create cluster --name "$CLUSTER_NAME" --wait 120s

echo "Building and loading lab counter image ($COUNTER_IMAGE)..."
docker build -t "$COUNTER_IMAGE" -f "$REPO_ROOT/testing/kind/counter/Dockerfile" "$REPO_ROOT/testing/kind/counter"
kind load docker-image "$COUNTER_IMAGE" --name "$CLUSTER_NAME"

echo "Applying workloads ($WORKLOADS)..."
kubectl apply -f "$WORKLOADS"

echo "Waiting for rollouts (timeout $ROLLOUT_TIMEOUT)..."
for target in "${ROLLOUT_TARGETS[@]}"; do
  if ! kubectl rollout status "$target" -n "$NS" --timeout="$ROLLOUT_TIMEOUT"; then
    echo "error: $target did not become ready."
    dump_diagnostics
    exit 1
  fi
done

echo ""
echo "Workloads ready."

if [[ "${KZERO_KIND_E2E_KZERO:-1}" != "1" ]]; then
  echo "KZERO_KIND_E2E_KZERO=0: skipping kzero (workloads-only smoke passed)."
  exit 0
fi

command -v "$KZERO_BIN" >/dev/null 2>&1 || {
  echo "error: kzero binary not found (set KZERO_BIN or install kzero — see https://github.com/hrodrig/kzero/releases)"
  exit 1
}

parse_count_html() {
  local html="$1"
  if [[ "$html" =~ data-e2e-count=\"([0-9]+)\" ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo ""
  fi
}

# Ephemeral curl pod in $NS — same DNS as counter Service.
# Use --attach without -i to avoid kubectl TTY/session noise in captured stdout.
counter_curl_get() {
  local path="$1"
  local name="e2e-curl-$RANDOM"
  kubectl run "$name" --rm --attach --restart=Never -n "$NS" \
    --image="$E2E_CURL_IMG" \
    -- curl -sS --connect-timeout 10 --max-time 30 "http://counter:8080${path}" 2>/dev/null
}

# Same as a browser: POST the HTML form to /increment, follow 303 to /, return final HTML.
counter_ui_post_increment() {
  local name="e2e-curl-$RANDOM"
  kubectl run "$name" --rm --attach --restart=Never -n "$NS" \
    --image="$E2E_CURL_IMG" \
    -- curl -sS -L --connect-timeout 10 --max-time 30 \
    -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data "go=1" \
    "http://counter:8080/increment" 2>/dev/null
}

echo "--- Phase 1: initialize — lab counter UI (GET /, POST /increment) ---"
html=""
c=""
for ((attempt = 1; attempt <= 30; attempt++)); do
  html="$(counter_curl_get "/")"
  c="$(parse_count_html "$html")"
  if [[ "$c" == "0" ]]; then
    break
  fi
  sleep 2
done
if [[ "$c" != "0" ]]; then
  echo "error: expected initial count 0 from UI, parsed='$c' (after retries; missing data-e2e-count?)"
  [[ -n "${html:-}" ]] && echo "Last response (first 500 bytes): ${html:0:500}"
  dump_diagnostics
  exit 1
fi
expect=1
for _ in 1 2 3; do
  html="$(counter_ui_post_increment)"
  c="$(parse_count_html "$html")"
  if [[ "$c" != "$expect" ]]; then
    echo "error: after UI increment expected count $expect, parsed='$c'"
    dump_diagnostics
    exit 1
  fi
  expect=$((expect + 1))
done
echo "Counter is at 3 (browser: kubectl port-forward -n $NS svc/counter 8080:8080 → http://127.0.0.1:8080/)."

echo ""
echo "Running kzero (binary: $KZERO_BIN)..."

echo "--- Phase 2: kzero reset (dry-run plan, live down + live up) ---"
echo "--- kzero analyze (live config) ---"
analyze_out="$(mktemp)"
if ! "$KZERO_BIN" analyze --config "$CFG_LIVE" >"$analyze_out"; then
  echo "error: kzero analyze failed"
  cat "$analyze_out" 2>/dev/null || true
  rm -f "$analyze_out"
  dump_diagnostics
  exit 1
fi
for needle in '[down]' '[up]' 'Run execution:' 'Cluster validation:' 'OK  deployment.kzero-e2e/web' 'deployment.kzero-e2e/postgres'; do
  if ! grep -q "$needle" "$analyze_out"; then
    echo "error: kzero analyze output missing expected line containing: $needle"
    cat "$analyze_out"
    rm -f "$analyze_out"
    dump_diagnostics
    exit 1
  fi
done
cat "$analyze_out"
rm -f "$analyze_out"

echo "--- kzero down (dry-run plan) ---"
"$KZERO_BIN" down --config "$CFG_DRY"

echo "--- kzero down (live) ---"
"$KZERO_BIN" down --config "$CFG_LIVE"

echo "Verifying desired replicas after down..."
want=0
for res in "${REPLICA_CHECK[@]}"; do
  got="$(kubectl get -n "$NS" "$res" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "")"
  if [[ "$got" != "$want" ]]; then
    echo "error: expected $res .spec.replicas=$want, got '$got'"
    dump_diagnostics
    exit 1
  fi
done

echo "--- kzero up (live) ---"
"$KZERO_BIN" up --config "$CFG_LIVE"

echo "Waiting for rollouts after up..."
for target in "${ROLLOUT_TARGETS[@]}"; do
  if ! kubectl rollout status "$target" -n "$NS" --timeout="$ROLLOUT_TIMEOUT"; then
    echo "error: $target not ready after up."
    dump_diagnostics
    exit 1
  fi
done

echo "--- Phase 3: validate — UI counter back to zero after reset ---"
html=""
c=""
for ((attempt = 1; attempt <= 30; attempt++)); do
  html="$(counter_curl_get "/")"
  c="$(parse_count_html "$html")"
  if [[ "$c" == "0" ]]; then
    break
  fi
  if [[ -n "$c" ]]; then
    echo "error: expected count 0 from UI after kzero up, got '$c'"
    dump_diagnostics
    exit 1
  fi
  sleep 2
done
if [[ "$c" != "0" ]]; then
  echo "error: expected count 0 from UI after kzero up, could not parse data-e2e-count after 30 attempts (parsed='$c')"
  [[ -n "${html:-}" ]] && echo "Last response (first 500 bytes): ${html:0:500}"
  dump_diagnostics
  exit 1
fi
echo "Counter is at $c (e2e_scratch was truncated on postgres pre-down)."

echo ""
echo "kzero kind e2e passed (Phase 4: cluster delete runs on script exit via trap)."
exit 0
