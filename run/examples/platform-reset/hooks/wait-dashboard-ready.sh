#!/bin/sh
set -euo pipefail

ns="${KZERO_STEP_NAMESPACE:?}"
slave="${KZERO_STEP_NAME:?}"
timeout="${KZERO_MASTER_WAIT_TIMEOUT:-10m}"

case "$slave" in
  *-slave) dashboard="${slave%-slave}-dashboard" ;;
  *) echo "wait-dashboard-ready: not a *-slave step: ${slave}" >&2; exit 1 ;;
esac

kubectl -n "$ns" rollout status "deployment/${dashboard}" --timeout="$timeout"
