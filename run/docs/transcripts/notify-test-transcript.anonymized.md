# Transcript: `kzero notify test` (anonymized)

**Date:** 2026-06-12  
**kzero version:** 0.7.3

```
$ kzero notify test --config kzero-full-reset.sample.yml
2026/06/12 09:20:00: kzero - [INF] - notify test: sending sample messages to configured webhooks
2026/06/12 09:20:01: kzero - [INF] - slack: test message sent (event=test)

$ kzero notify test --config kzero-full-reset.sample.yml --event start
2026/06/12 09:20:05: kzero - [INF] - slack: test message sent (event=start)

$ kzero notify test --config kzero-full-reset.sample.yml --event success
2026/06/12 09:20:08: kzero - [INF] - slack: test message sent (event=success)

$ kzero notify test --config kzero-full-reset.sample.yml --event error
2026/06/12 09:20:11: kzero - [INF] - slack: test message sent (event=error)
```

Slack attachment title examples: **`kzero started`**, **`kzero completed`**, **`kzero failed`**. Footer: **`kzero v0.7.3`**.
