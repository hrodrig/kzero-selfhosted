#!/bin/bash
# Bootstrap the kzero-demo lab stack on a REAL cluster (not kind).
# Installs Bitnami Helm releases (public OCI) + WordPress Deployment.
#
# Usage: ./install-demo.sh
# Requires: kubectl, helm, KUBECONFIG (or .env)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-$SCRIPT_DIR/.env}"
NS="${KZERO_DEMO_NAMESPACE:-kzero-demo}"
HELM_DIR="$SCRIPT_DIR/helm"
BOOTSTRAP_DIR="$SCRIPT_DIR/bootstrap"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}ℹ️  $1${NC}"; }
ok() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
err() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# shellcheck source=lib/kubeconfig.sh
source "$SCRIPT_DIR/lib/kubeconfig.sh"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +a
fi

if ! command -v kubectl >/dev/null 2>&1; then
  err "kubectl not found on PATH"
fi
if ! command -v helm >/dev/null 2>&1; then
  err "helm not found on PATH"
fi

kzero_demo_apply_kubeconfig || err "Fix KUBECONFIG in .env or use kubectl default (~/.kube/config)"

log "Kubeconfig: $(kzero_demo_kube_config_label); context: $(kzero_demo_kube_context_label)"

if ! kubectl cluster-info >/dev/null 2>&1; then
  err "Cannot reach cluster — check: kubectl config current-context (uses ~/.kube/config when KUBECONFIG is unset)"
fi

helm_install() {
  local release="$1"
  local manifest="$HELM_DIR/${release}.yaml"
  [[ -f "$manifest" ]] || err "Missing $manifest"
  local chart version
  chart="$(grep -E '^chart:' "$manifest" | sed 's/^chart:[[:space:]]*//')"
  version="$(grep -E '^version:' "$manifest" | sed 's/^version:[[:space:]]*//' | tr -d '"')"
  local values_file
  values_file="$(grep -E '^[[:space:]]*- ' "$manifest" | head -1 | sed 's/^[[:space:]]*- //')"
  log "helm upgrade --install $release ($version) in $NS"
  helm upgrade --install "$release" "$chart" \
    --namespace "$NS" \
    --version "$version" \
    -f "$HELM_DIR/$values_file" \
    --wait --timeout 15m
}

warn "This installs a lab stack into namespace '$NS' on cluster: $(kubectl config current-context 2>/dev/null || echo '?')"
read -r -p "Continue? [y/N] " ans
ans="$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')"
[[ "$ans" == "y" || "$ans" == "yes" ]] || err "Aborted"

log "Applying namespace and WordPress manifests"
kubectl apply -f "$BOOTSTRAP_DIR/namespace.yaml"
kubectl apply -f "$BOOTSTRAP_DIR/wordpress-secret.yaml"

log "Installing infra Helm releases (Bitnami public OCI)"
helm_install demo-postgresql
helm_install demo-rabbitmq
helm_install demo-redis
helm_install demo-mysql

log "Applying WordPress Deployment (requires demo-mysql Service)"
kubectl apply -f "$BOOTSTRAP_DIR/wordpress-deployment.yaml"
kubectl apply -f "$BOOTSTRAP_DIR/wordpress-service.yaml"

kubectl -n "$NS" rollout status deployment/wordpress --timeout=10m

ok "Demo stack ready in namespace $NS"
echo ""
echo "Next:"
echo "  ./run-kzero analyze"
echo "  ./run-kzero down          # dry-run"
echo "  ./run-kzero --live reset  # destructive — kzero-demo only"
