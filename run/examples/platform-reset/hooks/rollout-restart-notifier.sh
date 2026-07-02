#!/bin/sh
set -euo pipefail

ns="${KZERO_STEP_NAMESPACE:-platform}"

kubectl -n "$ns" rollout restart deployment/notifier
kubectl -n "$ns" rollout restart statefulset/notifier-slave

echo "rollout-restart-notifier: deployment and statefulset restarted"
