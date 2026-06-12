# Notifications — full reset example

How to exercise **Slack** notifications with **[kzero v0.7.3+](https://github.com/hrodrig/kzero/releases/tag/v0.7.3)** and the **full-reset-example** profile (namespace **`kzero-demo`** on a lab cluster).

---

## Configuration

**YAML** (`notify.slack` in **`kzero-full-reset.sample.yml`**) — leave disabled in Git; enable via environment:

```bash
export KZERO_NOTIFY_SLACK_ENABLED=true
export KZERO_NOTIFY_SLACK_WEBHOOK_URL="https://hooks.slack.com/services/…"
```

Other supported overrides: **`KZERO_NOTIFY_SLACK_WEBHOOK_URL`** maps to **`notify.slack.webhook_url`**. See [kzero SPECIFICATIONS — notify](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md).

Notifications fire on **`live`** pipeline start, success, and failure only (not dry-run).

---

## Slack message shape (v0.7.3)

Attachments use color by outcome:

| Event | Color | Title |
|-------|-------|-------|
| Start | `#439FE0` | **`kzero started`** |
| Success | `good` | **`kzero completed`** |
| Failure | `danger` | **`kzero failed`** |

Fields typically include **Cluster**, **Client**, **Context**, **User**, **Mode**, **Duration**. Footer: **`kzero v0.7.3`**.

---

## Test without mutating the cluster

```bash
cd run/examples/full-reset-example
source .env   # webhook vars set

kzero notify test --config kzero-full-reset.sample.yml
kzero notify test --config kzero-full-reset.sample.yml --event start
kzero notify test --config kzero-full-reset.sample.yml --event success
kzero notify test --config kzero-full-reset.sample.yml --event error
```

Sample output: [transcripts/notify-test-transcript.anonymized.md](transcripts/notify-test-transcript.anonymized.md).

---

## Live reset

With notify env vars set, **`./run-kzero --live reset`** sends **started** at pipeline begin and **completed** after **`infra_probe`** succeeds (or **failed** on error).

Do **not** commit webhook URLs — use **`.env`** or your secret manager.

← [full-reset-validation.md](full-reset-validation.md)
