# kzero-selfhosted

![kzero-selfhosted — operator docs and examples for the kzero CLI](assets/kzero-selfhosted-hero.png)

[![Version](https://img.shields.io/badge/version-0.1.2-blue)](https://github.com/hrodrig/kzero-selfhosted/releases)
[![Release](https://img.shields.io/github/v/release/hrodrig/kzero-selfhosted?label=release)](https://github.com/hrodrig/kzero-selfhosted/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![App image on GHCR](https://img.shields.io/badge/image-ghcr.io%2Fhrodrig%2Fkzero-2496ED?logo=github)](https://github.com/hrodrig/kzero/pkgs/container/kzero)
[![kzero app](https://img.shields.io/badge/app-hrodrig%2Fkzero-181717?logo=github)](https://github.com/hrodrig/kzero)

Operator-focused **extras** for **[kzero](https://github.com/hrodrig/kzero)**: how to run the CLI on a **bastion or automation host**, optional **`docker run`** notes, and a **minimal example YAML**.

**kzero is not self-contained:** it drives the cluster by executing external **`kubectl`** and (when you use **`release.*`** steps) **`helm`**. You must install those tools and maintain **`kubeconfig`** (or equivalent) on the host. The **GHCR** image ships only the **`kzero`** binary — adequate for **`analyze`** / **`version`**, not for **`live`** pipelines unless you add **`kubectl`** / **`helm`** yourself.

**kzero** is not an in-cluster workload — run it where **`kubectl`** and **`kubeconfig`** already work.

**Releases:** Root **`VERSION`** and Git tags **`v<semver>`** on **`main`** name snapshots of **this** repository. Work in progress may land on **`develop`** first.

---

## Table of contents

- [Where to run kzero](#where-to-run-kzero)
- [Local e2e (kind)](#local-e2e-kind)
- [Repository layout](#repository-layout)
- [Policies](#policies)
- [License](#license)

---

## Where to run kzero

| Goal | Start here |
|------|----------------|
| **Production** (`live` **down** / **up** / **reset**) | Install **kzero**, **`kubectl`**, and **`helm`** (if config uses **`release.*`**) on a bastion or job runner; configure **`kubeconfig`** — [kzero README — First run](https://github.com/hrodrig/kzero/blob/main/README.md#first-run) |
| **`docker run`** (mostly **`analyze`** / **`version`**) | [run/docker/README.md](run/docker/README.md) |
| **Example config** | [run/examples/kzero.sample.yml](run/examples/kzero.sample.yml) |
| **Disposable cluster + kzero** | [testing/kind/README.md](testing/kind/README.md) — **`make test-kind-e2e`** (tested with **kzero** [v0.4.0+](https://github.com/hrodrig/kzero/releases/tag/v0.4.0)) |

Published **`ghcr.io/hrodrig/kzero`** images are **distroless** (only the **`kzero`** binary). **`analyze`** does not call the API server. **`live`** pipelines require **`kubectl`** and **`helm`** (when applicable) **on the host** — the image does not bundle them.

---

## Local e2e (kind)

From the repo root, with **Docker**, **kind**, **kubectl**, and **kzero** [v0.4.0+](https://github.com/hrodrig/kzero/releases/tag/v0.4.0) installed:

```bash
make test-kind-e2e
```

This creates a **kind** cluster, builds and loads the **lab counter** image (Postgres-backed **`e2e_scratch`**), applies **Deployments** (web, counter, Postgres, Redis, RabbitMQ, lightweight **obs**), a **StatefulSet** (nginx + PVC), then runs **Phase 1** (HTML UI: **0** → three **Increment** form posts → **3**), **Phase 2** **`kzero analyze`** + **`kzero down`** (dry-run then live) and **`kzero up`** with **`run.execution: native`**, **Phase 3** (UI shows **0** again), and **Phase 4** (delete cluster on exit). Workloads-only smoke (**no** kzero binary): **`make test-kind-workloads`**. Details: **[testing/kind/README.md](testing/kind/README.md)**.

---

## Repository layout

| Path | Purpose |
|------|---------|
| **`run/docker/`** | **`docker run`** examples |
| **`run/examples/`** | **`kzero.sample.yml`** for copy-paste |
| **`assets/`** | README hero and other images |
| **`testing/`** | **kind** e2e scripts and manifests ([testing/README.md](testing/README.md)) |
| **`Makefile`** | **`make help`**, **`make test-kind-e2e`**, **`make test-kind-workloads`** |
| **`AGENTS.md`** | Guidelines for agents and contributors |
| **`CODE_OF_CONDUCT.md`** | Contributor Covenant |
| **`CHANGELOG.md`** | This repo’s release notes (upstream app: **kzero** changelog) |

---

## Policies

- **[AGENTS.md](AGENTS.md)** — scope, versioning.
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — PR expectations.
- **[SECURITY.md](SECURITY.md)** — reporting vulnerabilities.
- **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** — community standards.
- **[CHANGELOG.md](CHANGELOG.md)** — history of **kzero-selfhosted** (not the **kzero** app).

---

## License

See **[LICENSE](LICENSE)** (MIT).
