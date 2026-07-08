#!/usr/bin/env bash
# kind + in-cluster kzero Jobs (analyze → down → up). See testing/kind/in-cluster/README.md.
# Requires: docker, kind, kubectl.
# Optional: KZERO_KIND_IN_CLUSTER_CLUSTER, KZERO_IN_CLUSTER_IMAGE, KZERO_IN_CLUSTER_BUILD=1,
#           KZERO_REPO (local kzero clone for docker build), KZERO_KIND_NO_CLEANUP, KZERO_KIND_JOB_TIMEOUT
set -euo pipefail

CLUSTER_NAME="${KZERO_KIND_IN_CLUSTER_CLUSTER:-kzero-in-cluster-smoke}"
JOB_TIMEOUT="${KZERO_KIND_JOB_TIMEOUT:-300s}"
ROLLOUT_TIMEOUT="${KZERO_KIND_ROLLOUT_TIMEOUT:-120s}"
DEFAULT_IMAGE="ghcr.io/hrodrig/kzero:v0.9.0"
KZERO_IN_CLUSTER_IMAGE="${KZERO_IN_CLUSTER_IMAGE:-$DEFAULT_IMAGE}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFESTS="$REPO_ROOT/run/in-cluster/manifests"

dump_diagnostics() {
  echo ""
  echo "========== diagnostics =========="
  kubectl get pods,jobs -n kzero-system -o wide 2>/dev/null || true
  kubectl get pods,deploy -n kzero-smoke-a -o wide 2>/dev/null || true
  kubectl get pods,deploy -n kzero-smoke-b -o wide 2>/dev/null || true
  echo ""
  kubectl get events -A --sort-by='.lastTimestamp' 2>/dev/null | tail -40 || true
  echo "========== end diagnostics =========="
  echo ""
}

cleanup() {
  if [[ -n "${KZERO_KIND_NO_CLEANUP:-}" ]]; then
    echo "KZERO_KIND_NO_CLEANUP is set; keeping kind cluster: $CLUSTER_NAME"
    echo "  kubectl config use-context kind-$CLUSTER_NAME"
    return 0
  fi
  echo "Teardown: destroying kind cluster --name $CLUSTER_NAME"
  kind delete cluster --name "$CLUSTER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

for cmd in docker kind kubectl; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "error: '$cmd' not found on PATH"
    exit 1
  }
done

for f in \
  "$MANIFESTS/00-namespace.yaml" \
  "$MANIFESTS/01-smoke-workloads.yaml" \
  "$MANIFESTS/02-rbac.yaml" \
  "$MANIFESTS/03-configmap.yaml" \
  "$MANIFESTS/job-analyze.yaml" \
  "$MANIFESTS/job-down.yaml" \
  "$MANIFESTS/job-up.yaml"; do
  test -f "$f" || {
    echo "error: missing $f"
    exit 1
  }
done

load_kzero_image() {
  if [[ "${KZERO_IN_CLUSTER_BUILD:-}" == "1" ]]; then
    local repo="${KZERO_REPO:-}"
    if [[ -z "$repo" && -d "$REPO_ROOT/../kzero" ]]; then
      repo="$REPO_ROOT/../kzero"
    fi
    if [[ -z "$repo" || ! -f "$repo/Dockerfile" ]]; then
      echo "error: KZERO_IN_CLUSTER_BUILD=1 but KZERO_REPO (or ../kzero) with Dockerfile not found"
      exit 1
    fi
    echo "Building kzero image from $repo → $KZERO_IN_CLUSTER_IMAGE"
    docker build -t "$KZERO_IN_CLUSTER_IMAGE" -f "$repo/Dockerfile" "$repo"
  else
    echo "Pulling $KZERO_IN_CLUSTER_IMAGE (set KZERO_IN_CLUSTER_BUILD=1 to build from local kzero clone)"
    docker pull "$KZERO_IN_CLUSTER_IMAGE"
  fi
  echo "Loading image into kind..."
  kind load docker-image "$KZERO_IN_CLUSTER_IMAGE" --name "$CLUSTER_NAME"
}

apply_job() {
  local manifest="$1"
  sed "s|${DEFAULT_IMAGE}|${KZERO_IN_CLUSTER_IMAGE}|g" "$manifest" | kubectl apply -f -
}

wait_job_ok() {
  local name="$1"
  echo "Waiting for job/$name (timeout $JOB_TIMEOUT)..."
  if ! kubectl wait -n kzero-system --for=condition=complete "job/$name" --timeout="$JOB_TIMEOUT"; then
    echo "error: job/$name did not complete."
    kubectl logs -n kzero-system "job/$name" 2>/dev/null || true
    dump_diagnostics
    exit 1
  fi
  local succ
  succ="$(kubectl get job "$name" -n kzero-system -o jsonpath='{.status.succeeded}' 2>/dev/null || echo 0)"
  if [[ "$succ" != "1" ]]; then
    echo "error: job/$name failed (succeeded=$succ)."
    kubectl logs -n kzero-system "job/$name" 2>/dev/null || true
    dump_diagnostics
    exit 1
  fi
  echo "--- logs job/$name ---"
  kubectl logs -n kzero-system "job/$name" 2>/dev/null || true
  echo "--- end logs ---"
}

expect_replicas() {
  local ns="$1"
  local deploy="$2"
  local want="$3"
  local got
  got="$(kubectl get deploy "$deploy" -n "$ns" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo missing)"
  if [[ "$got" != "$want" ]]; then
    echo "error: deployment/$deploy in $ns expected replicas=$want got $got"
    dump_diagnostics
    exit 1
  fi
  echo "ok: deployment/$deploy in $ns replicas=$got"
}

echo "Phase 1: kind cluster $CLUSTER_NAME"
kind create cluster --name "$CLUSTER_NAME" --wait 120s

echo "Phase 2: kzero runner image"
load_kzero_image

echo "Phase 3: apply in-cluster manifests"
kubectl apply -f "$MANIFESTS/00-namespace.yaml"
kubectl apply -f "$MANIFESTS/01-smoke-workloads.yaml"
kubectl apply -f "$MANIFESTS/02-rbac.yaml"
kubectl apply -f "$MANIFESTS/03-configmap.yaml"

echo "Waiting for smoke workloads..."
kubectl rollout status deployment/app -n kzero-smoke-a --timeout="$ROLLOUT_TIMEOUT"
kubectl rollout status deployment/app -n kzero-smoke-b --timeout="$ROLLOUT_TIMEOUT"

echo "Phase 4: kzero analyze (in-cluster Job)"
kubectl delete job kzero-analyze -n kzero-system --ignore-not-found --wait=true 2>/dev/null || true
apply_job "$MANIFESTS/job-analyze.yaml"
wait_job_ok kzero-analyze

echo "Phase 5: kzero down (live)"
kubectl delete job kzero-down -n kzero-system --ignore-not-found --wait=true 2>/dev/null || true
apply_job "$MANIFESTS/job-down.yaml"
wait_job_ok kzero-down
expect_replicas kzero-smoke-a app 0
expect_replicas kzero-smoke-b app 0

echo "Phase 6: kzero up (live)"
kubectl delete job kzero-up -n kzero-system --ignore-not-found --wait=true 2>/dev/null || true
apply_job "$MANIFESTS/job-up.yaml"
wait_job_ok kzero-up
expect_replicas kzero-smoke-a app 1
expect_replicas kzero-smoke-b app 1

echo ""
echo "in-cluster kind smoke passed (analyze → down → up, two namespaces)."
