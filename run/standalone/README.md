# Standalone (bastion / cron / systemd)

Run **`kzero`** from a **[release binary](https://github.com/hrodrig/kzero/releases)** or **`brew install hrodrig/kzero/kzero`** on a trusted host with **`kubectl`**, optional **`helm`**, and **`kubeconfig`**.

## Prerequisites

- **`kzero`** on **`PATH`** (or set full path in scripts)
- **`KUBECONFIG`** or **`run.kubeconfig`** in your profile YAML
- Profile directory with **`helm.workspace`**, hook scripts, and relative **`custom:`** paths — see [run/examples/](../examples/README.md)

## Cron example

```cron
# Nightly staging reset (live) — review dry-run first
0 3 * * * root cd /opt/kzero/profiles/staging && \
  KUBECONFIG=/etc/kzero/staging.kubeconfig KZERO_RUN_MODE=live \
  /usr/bin/kzero reset --config ./kzero.yaml >> /var/log/kzero-reset.log 2>&1
```

Use absolute paths for **`command.kubectl`** / **`command.helm`** in YAML when cron has a minimal **`PATH`**.

## systemd one-shot

```ini
[Unit]
Description=kzero pipeline up (staging)
After=network-online.target

[Service]
Type=oneshot
WorkingDirectory=/opt/kzero/profiles/staging
Environment=KUBECONFIG=/etc/kzero/staging.kubeconfig
Environment=KZERO_RUN_MODE=live
ExecStart=/usr/bin/kzero up --config ./kzero.yaml
```

Enable a **timer** if you need periodic runs; **kzero** is not a daemon.

## CI and YES-gated wrappers

Full patterns (GitHub Actions skeleton, **`printf 'YES\n' | ./run-operator`**, env overrides): **[run/docs/automation-and-pipelines.md](../docs/automation-and-pipelines.md)**.

← [Back to run/README](../README.md)
