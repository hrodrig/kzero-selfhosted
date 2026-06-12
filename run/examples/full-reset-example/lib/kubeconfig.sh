# shellcheck shell=bash
# Resolve kubeconfig after sourcing .env — unset fake placeholders; default = kubectl (~/.kube/config).
_kzero_demo_kube_placeholder='/path/to/your/lab-kubeconfig'

kzero_demo_apply_kubeconfig() {
  local candidate=""
  if [[ -n "${KZERO_RUN_KUBECONFIG:-}" ]]; then
    candidate="$KZERO_RUN_KUBECONFIG"
  elif [[ -n "${KUBECONFIG:-}" && "$KUBECONFIG" != "$_kzero_demo_kube_placeholder" ]]; then
    candidate="$KUBECONFIG"
  fi
  if [[ -n "$candidate" ]]; then
    if [[ ! -f "$candidate" ]]; then
      echo "❌ KUBECONFIG file not found: $candidate" >&2
      return 1
    fi
    export KUBECONFIG="$candidate"
  else
    unset KUBECONFIG
  fi
}

kzero_demo_kube_context_label() {
  kubectl config current-context 2>/dev/null || echo '?'
}

kzero_demo_kube_config_label() {
  if [[ -n "${KUBECONFIG:-}" ]]; then
    echo "$KUBECONFIG"
  elif [[ -f "${HOME}/.kube/config" ]]; then
    echo "${HOME}/.kube/config (default)"
  else
    echo "kubectl default search path"
  fi
}
