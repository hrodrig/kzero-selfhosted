# Changelog

All notable changes to **kzero-selfhosted** (operator documentation and examples for this repository only) are documented here. For the **kzero** CLI application, see [kzero CHANGELOG](https://github.com/hrodrig/kzero/blob/main/CHANGELOG.md).

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.4...HEAD
[0.1.4]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/hrodrig/kzero-selfhosted/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/hrodrig/kzero-selfhosted/releases/tag/v0.1.0
