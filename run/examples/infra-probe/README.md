# Infra probe reference (Redis)

Anonymous Bitnami Redis probe for **`infra_probe`** / **`kzero probe`**.

| File | Shell path (`run.execution: shell`) | Native path (`run.execution: native`) |
|------|-------------------------------------|----------------------------------------|
| `kzero-probe-redis-values.yaml` | Required | Required |
| `kzero-probe-redis.sh` | Copy to `<helm.workspace>/probe-redis.sh` | Not used |
| `kzero-probe-redis.yaml` | — | Copy to `<helm.workspace>/probe-redis.yaml` |
| `kzero-infra-probe-redis.sample.yaml` | YAML fragment | — |
| `kzero-infra-probe-redis-native.sample.yaml` | — | YAML fragment |

Cookbook: [kzero docs/examples/infra-probe.md](https://github.com/hrodrig/kzero/blob/main/docs/examples/infra-probe.md).

In-cluster RBAC for native probe (Helm SDK + PVC checks): see [run/in-cluster/README.md](../../in-cluster/README.md).
