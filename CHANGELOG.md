# Changelog

All notable changes to **kzero-selfhosted** (operator documentation and examples for this repository only) are documented here. For the **kzero** CLI application, see [kzero CHANGELOG](https://github.com/hrodrig/kzero/blob/main/CHANGELOG.md).

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.13] - 2026-07-16

### Changed

- **Upstream pin:** [kzero v1.0.1](https://github.com/hrodrig/kzero/releases/tag/v1.0.1) in in-cluster Job manifests, kind smoke defaults, **`docker run`** examples, and operator docs (was **v1.0.0**).
- **Operator docs:** recommend **v1.0.1** for live **`reset`** on slow/remote APIs (retry treats **`connection lost`** / **`http2: client connection lost`** as transient).

## [0.1.12] - 2026-07-15

### Changed

- **Upstream pin:** [kzero v1.0.0](https://github.com/hrodrig/kzero/releases/tag/v1.0.0) in in-cluster Job manifests, kind smoke defaults, **`docker run`** examples, and operator docs (was **v0.9.0**).
- **Operator docs:** document **v1.0.0** stable contract (default **`run.execution: native`**, exit codes **0–4**, **`kzero doctor`**); recommend **v1.0.0** for **`platform-reset`** and **`full-reset-example`**.

## [0.1.11] - 2026-07-08

### Added

- **`run/examples/platform-reset/`** — anonymized large maintenance profile (**`platform`** namespace): generic workloads, full **`helm/`** workspace (PostgreSQL, RabbitMQ, Redis, five jobstores, optional state-store/mongodb), hooks, **`run-kzero`** with cluster slug log names, anonymized live reset log fixture.
- **`run/docs/transcripts/reset-live-transcript-platform.anonymized.md`** — summary of ~9m45s live reset (throttled progress lines, hook ordering).

### Changed

- **Upstream pin:** [kzero v0.9.0](https://github.com/hrodrig/kzero/releases/tag/v0.9.0) in in-cluster Job manifests, kind smoke defaults, **`docker run`** examples, and operator docs (was **v0.8.1**).
- **Operator docs:** cross-links to [kzero deployment-models](https://github.com/hrodrig/kzero/blob/main/docs/deployment-models.md); document **v0.9.0** features used by wrappers (**`kzero target --output slug`**, graceful **SIGINT/SIGTERM** shutdown, **`notify.require_delivery`**).
- **Example READMEs:** **v0.9.0** recommended for **`platform-reset`** and **`full-reset-example`** (bastion live **`reset`**).

## [0.1.10] - 2026-06-29

### Changed

- **Upstream pin:** [kzero v0.8.1](https://github.com/hrodrig/kzero/releases/tag/v0.8.1) in in-cluster Job manifests, kind smoke defaults, and operator docs (was **v0.7.3**).
- **`run/examples/full-reset-example/kzero-full-reset.sample.yml`:** add **`run.api_watchdog`** (recommended for live **`reset`** on remote API paths; ships in **kzero v0.8.0+**).
- **Operator docs:** sync network-loss / automation cross-links for shipped **0.8.x** features (**API watchdog**, notify **`[ERR]`**, **`pipeline.stalled`**) — no longer “until **v0.8.0**”.
- **`run/docker/README.md`:** example image tag **`v0.8.1`**.

## [0.1.9] - 2026-06-12

### Added

- **`run/examples/full-reset-example/`** — **real-cluster** lab in namespace **`kzero-demo`**: WordPress + Bitnami MySQL/PostgreSQL/Redis/RabbitMQ (public OCI), **`install-demo.sh`** / **`uninstall-demo.sh`**, maintenance **`reset`** profile (**`truncate-demo-postgres`**, PVC wipe, **`infra_probe`**), **`run-kzero`** wrapper.
- **`run/docs/full-reset-validation.md`** — validation runbook (steps 0–7, success criteria, troubleshooting).
- **`run/docs/notifications-full-reset.md`** — Slack attachments, **`KZERO_NOTIFY_*`**, **`kzero notify test`**.
- **`run/docs/transcripts/`** — anonymized CLI transcripts (analyze, down, up, probe, reset live, notify test).
- **`run/docs/automation-and-pipelines.md`:** link to upstream [pipeline-network-loss](https://github.com/hrodrig/kzero/blob/develop/docs/examples/pipeline-network-loss.md) cookbook and **0.8.x** plan for production bastion resets.

### Changed

- **Upstream pin:** [kzero v0.7.3](https://github.com/hrodrig/kzero/releases/tag/v0.7.3) in in-cluster Job manifests and kind smoke defaults (timestamped logs, Slack notify polish, **`KZERO_NOTIFY_*`** env binding).

## [0.1.8] - 2026-06-11

### Changed

- **In-cluster Jobs:** pin **`ghcr.io/hrodrig/kzero:v0.7.2`** in manifests and kind smoke defaults (upstream **0.7.x** band close).

### Added

- **`run/in-cluster/`** — reference **Job**, **ServiceAccount**, **ClusterRole**, **ConfigMap**, and two-namespace scale smoke (**`kzero-smoke.sample.yml`**, **`manifests/`**). Documents that pipeline namespaces differ from the Job namespace.
- **`make test-kind-in-cluster`** — **`testing/scripts/kzero-in-cluster-kind-smoke.sh`**: kind cluster + in-cluster **`analyze` → `down` → `up`** Jobs (see **`testing/kind/in-cluster/README.md`**).
- **Native infra probe** sample and RBAC updates (**PR6** alignment with [kzero v0.7.2](https://github.com/hrodrig/kzero/releases/tag/v0.7.2)).

## [0.1.7] - 2026-06-10

### Added

- **GitHub Actions:** [`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs **`make release-check`** on **`develop`** / **`main`** PRs.
- **GitHub Actions:** [`.github/workflows/release.yml`](.github/workflows/release.yml) publishes a **GitHub Release** from **`CHANGELOG.md`** on **`v*`** tag push (or **`workflow_dispatch`** to refresh an existing tag).
- **`testing/scripts/release-check.sh`** and **`extract-changelog.sh`** — VERSION / README badge / CHANGELOG gate and release notes extraction.

### Changed

- **`AGENTS.md`** is **local-only** (removed from Git; same as **kzero**). Use **CONTRIBUTING.md** for published scope and release flow.

## [0.1.6] - 2026-06-10

### Added

- **`run/docs/automation-and-pipelines.md`** — CI/cron, **`KZERO_RUN_MODE`**, YES-gated wrappers (from upstream kzero).
- **`run/examples/hooks/`** — reference **`pre`** / **`post`** shell scripts.
- **`run/examples/infra-probe/`** — anonymous Redis probe chart script, values, sample YAML fragment.
- **`run/standalone/README.md`** — bastion cron and systemd one-shot patterns.

### Changed

- **`run/README.md`** — operator hub (standalone, docker, examples, docs, kind e2e); pin **kzero** [v0.6.1+](https://github.com/hrodrig/kzero/releases/tag/v0.6.1).
- **`run/examples/README.md`**, **`run/docker/README.md`** — **`ghcr.io/hrodrig/kzero:v0.6.1`** in examples.
- **Upstream pin:** **kzero** [v0.6.1](https://github.com/hrodrig/kzero/releases/tag/v0.6.1) (man page, Homebrew, notify, verify, probe, preflight).

## [0.1.5] - 2026-06-04

### Changed

- **Upstream pin:** **kzero** [v0.5.3](https://github.com/hrodrig/kzero/releases/tag/v0.5.3) (live **per-step retry** since **v0.5.2**; **`run.worker_concurrency`** removed — pipelines are strictly sequential).
- **kind e2e / samples:** drop legacy **`run.worker_concurrency`** from YAML; **`kzero analyze`** smoke expects **`Retry:`** when **`retry.attempts`** is set.
- **Docs / Docker:** `ghcr.io/hrodrig/kzero:v0.5.3` in examples.

## [0.1.4] - 2026-06-04

### Changed

- **Upstream pin:** **kzero** [v0.5.1](https://github.com/hrodrig/kzero/releases/tag/v0.5.1) (`run.color`, server-side dry-run on native scale steps, **`Kubernetes target:`** on pipeline commands).
- **kind e2e:** dry-run config sets **`run.execution: native`**; **`kzero down` (dry-run)** smoke expects **`server-side dry-run ok`**; **`kzero analyze`** expects **`Run color:`**.
- **Docs / Docker:** `ghcr.io/hrodrig/kzero:v0.5.1` in examples.

## [0.1.3] - 2026-06-04

### Changed

- **Upstream pin:** **kzero** [v0.4.1](https://github.com/hrodrig/kzero/releases/tag/v0.4.1) (`analyze` **Cluster validation**, `run.execution` native path).
- **kind e2e:** **`kzero analyze`** smoke expects **Cluster validation** and **OK** for `deployment.kzero-e2e/web`.
- **Docs / Docker:** `ghcr.io/hrodrig/kzero:v0.4.1` in examples.

## [0.1.2] - 2026-06-04

### Changed

- **Upstream pin:** docs, Docker examples, and kind e2e target **kzero** [v0.4.0](https://github.com/hrodrig/kzero/releases/tag/v0.4.0) (`run.execution`, native workload executor).
- **kind e2e:** live config sets **`run.execution: native`**; **`kzero analyze`** smoke expects **`Run execution:`** on stdout.
- **Docs:** **`run/docker/README.md`** and example README describe **`Run execution:`** in **`analyze`** output; root **`README.md`** rewritten for **v0.4.0** scope and host requirements; **gghstats clones** badge.

## [0.1.1] - 2026-06-04

### Added

- **kind e2e:** **`pre:`** hook **`testing/kind/scripts/pg-wipe-e2e.sh`** on **`deployment.kzero-e2e/postgres`** (down pipeline) to **`TRUNCATE`** lab table **`public.e2e_scratch`** before scale-to-zero.
- **kind e2e lab counter:** **`testing/kind/counter/`** (Go HTTP app + Dockerfile), **Deployment/Service `counter`**, and **`kzero-kind-e2e.sh`** phases: drive the **HTML UI** (**`GET /`**, **`POST /increment`** with redirect), **kzero** reset, assert **`data-e2e-count`** is zero again, then delete cluster on exit.
- **kind e2e:** **`kzero analyze`** smoke checks for **`[down]`**, **`[up]`**, and key workload refs (requires **kzero** [v0.2.3+](https://github.com/hrodrig/kzero/releases/tag/v0.2.3)).

### Fixed

- **kind e2e:** replace **DaemonSet** `obs` with a **Deployment** (1× pause pod). **`kubectl scale`** has no **`/scale`** subresource on DaemonSets, so **kzero** live **down** failed with **NotFound** on modern clusters. Do not use **`exec: ["true"]`** readiness on **pause** (image has no shell); **`obs`** has no readiness probe so rollout succeeds once the container is running.
- **kind e2e script:** **`kubectl run`** for curl uses **`--attach`** without **`-i`** (avoids session banner on stdout) and **Phase 1 / Phase 3** poll the UI with retries so a parseable **`data-e2e-count`** is seen after cold starts.

### Changed

- **kind e2e workloads:** add **Postgres** (**Deployment** + `emptyDir`), **Redis**, **RabbitMQ**, **Services** for each; extend **`kzero-e2e*.yaml`** pipelines and **`kzero-kind-e2e.sh`** rollouts / replica checks; default **`KZERO_KIND_ROLLOUT_TIMEOUT`** **300s** in script and docs.
- **Docs:** Docker **`ghcr.io`** examples and **`analyze`** expectations aligned with **kzero** [0.2.3](https://github.com/hrodrig/kzero/releases/tag/v0.2.3) (normalized pipeline plan on stdout, **Deferred** summary, stderr warnings).

## [0.1.0] - 2026-05-13

### Added

- **Repository layout:** **`README.md`**, **`AGENTS.md`**, **`CONTRIBUTING.md`**, **`SECURITY.md`**, **`LICENSE`**, **`VERSION`**, **`Makefile`** (`make help` points to upstream **kzero** checks).
- **`run/docker/README.md`** — **`docker run`** examples; documents that **kzero** is **not self-contained** (requires external **`kubectl`** / **`helm`**, **`kubeconfig`** on the host).
- **`run/examples/kzero.sample.yml`** and **`run/examples/README.md`** — minimal **dry-run** sample aligned with **kzero** specifications.
- **`run/README.md`** — operator-focused overview (bastion / automation host; no in-cluster **kzero** workload).
- **`.gitignore`** whitelist pattern; **`.cursor/`** ignored for local-only rules.

### Removed

- **Docker Compose**, **`run/common/`**, Helm chart / **`run/kubernetes/`**, and Compose CI workflow — **kzero** is intended to run on hosts with real **`kubectl`**, not as a bundled Compose or in-cluster chart story.

[Unreleased]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.13...HEAD
[0.1.13]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.12...v0.1.13
[0.1.12]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.11...v0.1.12
[0.1.11]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.10...v0.1.11
[0.1.10]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.9...v0.1.10
[0.1.9]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.8...v0.1.9
[0.1.8]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/hrodrig/kzero-selfhosted/releases/tag/v0.1.0
