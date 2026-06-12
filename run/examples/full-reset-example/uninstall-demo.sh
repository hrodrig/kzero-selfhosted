#!/bin/bash
# Remove the kzero-demo lab stack from your cluster.
# Usage: ./uninstall-demo.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-$SCRIPT_DIR/.env}"
NS="${KZERO_DEMO_NAMESPACE:-kzero-demo}"

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# shellcheck source=lib/kubeconfig.sh
source "$SCRIPT_DIR/lib/kubeconfig.sh"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +a
fi

kzero_demo_apply_kubeconfig || { echo "❌ Invalid KUBECONFIG in .env" >&2; exit 1; }

warn "This deletes namespace '$NS' and ALL resources in it."
warn "Cluster context: $(kubectl config current-context 2>/dev/null || echo '?')"
read -r -p "Type DELETE to confirm: " ans
[[ "$ans" == "DELETE" ]] || { echo "Aborted."; exit 1; }

for rel in kzero-probe-redis demo-mysql demo-redis demo-rabbitmq demo-postgresql; do
  helm uninstall "$rel" -n "$NS" --ignore-not-found 2>/dev/null || true
done

kubectl delete namespace "$NS" --ignore-not-found --wait=true
echo "Namespace $NS removed."
