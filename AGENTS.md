# Agent Guidelines (kzero-selfhosted)

Context and instructions for AI coding agents working on **kzero-selfhosted** (operator docs, examples, and kind e2e for the **kzero** CLI). See [agents.md](https://agents.md/) for the format.

## Project overview

- **What it is:** Operator-focused **documentation and examples** for running **[kzero](https://github.com/hrodrig/kzero)** on a bastion or automation host — **`run/docker/`**, **`run/examples/`**, **`run/in-cluster/`** (reference Job + RBAC), and optional **kind** smoke under **`testing/`**. **No Go application code** in this repository.
- **Upstream application:** **[hrodrig/kzero](https://github.com/hrodrig/kzero)** owns the CLI, **`make release-check`**, unit/integration tests, and **`ghcr.io/hrodrig/kzero`** images. Config contract: **[SPECIFICATIONS.md](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md)**.
- **kzero is not self-contained:** host runs need **`kubectl`** (and often **`helm`** for **`release.*`** steps) plus a usable **kubeconfig** unless the profile is analyze-only or fully **native** scale paths. The published GHCR image is **distroless** (binary only). See root **README** — *kzero is not self-contained*.
- **`.cursor/`** is **local-only** (not committed). Shared agent policy belongs in tracked files such as this **AGENTS.md**, **README**, and **CONTRIBUTING.md**.

## Scope (operator vs product)

| **kzero-selfhosted** | **[hrodrig/kzero](https://github.com/hrodrig/kzero)** |
|----------------------|--------------------------------------------------------|
| Operator README, **`run/`**, kind e2e | Go CLI, engine, **`make release-check`**, packages |
| Example YAML under **`run/examples/`** | Canonical sample: **`configs/kzero.sample.yml`** |
| In-cluster Job smoke manifests | In-cluster execution implementation |

**Not here:** Docker Compose, Helm chart for a long-running in-cluster **kzero** controller, or bundled **`kubectl`** / **`helm`** in the runner image.

**Do not** invent YAML keys in examples that the application does not support — when upstream schema changes, update **`run/examples/*.yml`** and README snippets together.

## Checks and make targets

- **`make release-check`** — VERSION semver, README **Version** badge, CHANGELOG section for current VERSION (same gate as CI). Script: **`testing/scripts/release-check.sh`**.
- **`make test-kind-workloads`** — kind + sample workloads only (no **kzero** binary).
- **`make test-kind-e2e`** — full smoke: counter image, kind, **kzero** **down**/**up** (requires **kzero** on **`PATH`** or **`KZERO_BIN`**).
- **`make test-kind-in-cluster`** — **kzero** Jobs inside kind; optional **`KZERO_IN_CLUSTER_BUILD=1`** for unreleased **kzero**.

**Application gate:** clone **kzero** and run **`make release-check`** there before tagging an upstream app release.

## Git flow

- **Branches:** Work on **`develop`**. Topic branch → **PR into `develop`**. Release snapshot: **PR `develop` → `main`**, then annotated tag **`v<semver>`** on **`main`**.
- **Never** merge to **`main`**, create/push a release tag, or trigger [**.github/workflows/release.yml**](.github/workflows/release.yml) **without explicit user approval** in the current conversation.
- **Commits:** Show the proposed commit message and wait for user approval before `git commit`.
- **Language:** English only for code, comments, commit messages, docs, and README.

## Version bump (this repo — on `develop`, before merge/tag)

**`VERSION`** here is **kzero-selfhosted** semver — **not** the **kzero** app version. Image tags such as **`ghcr.io/hrodrig/kzero:v1.1.0`** follow **[kzero releases](https://github.com/hrodrig/kzero/releases)**; bump example pins when documenting a new upstream release.

| # | Artifact | Action |
|---|----------|--------|
| 1 | **`VERSION`** | New semver without `v` (e.g. `0.1.16`) |
| 2 | **`README.md`** | Static **Version** badge `version-<semver>` |
| 3 | **`CHANGELOG.md`** | Move `[Unreleased]` into `## [X.Y.Z] - YYYY-MM-DD`; update compare links |
| 4 | **Upstream pins** | When shipping a new **kzero** app release: update **`ghcr.io/hrodrig/kzero:v…`** in **`run/docker/`**, **`run/in-cluster/`**, kind scripts defaults, README “Tested with” |
| 5 | **Gate** | `make release-check` — run before tag |
| 6 | **Optional e2e** | `make test-kind-e2e` / `make test-kind-in-cluster` when **`testing/`** or **`run/`** changed materially |
| 7 | **Ship** | Merge `develop` → `main`, annotated tag `v<semver>`, push tag — **only after user explicitly approves** |

**After upstream kzero release (separate repo):** pin examples and docs here; optionally cut a **kzero-selfhosted** release if operator-facing notes changed. Marketing/install sites on GitLab may need pins separately.

## Upstream pin (e2e and docs)

Kind smoke and Docker examples currently assume **kzero** [v1.1.0+](https://github.com/hrodrig/kzero/releases/tag/v1.1.0): default **`run.execution: native`**, exit codes **0–4**, **`kzero doctor`**, **`kzero diff`**, notify/watchdog, **`command.shell`**, native **`job`/`cronjob`**, Helm SDK **v4**.

Key env overrides for tests: **`KZERO_BIN`**, **`KZERO_IN_CLUSTER_IMAGE`**, **`KZERO_REPO`**, **`KZERO_IN_CLUSTER_BUILD=1`**.

## Repository structure

- **`run/docker/`** — `docker run` notes (distroless image; mount kubeconfig).
- **`run/examples/`** — operator YAML samples; must match upstream SPEC **`schema_version`**.
- **`run/in-cluster/`** — Job + RBAC reference for **`run.execution: native`** inside the cluster.
- **`testing/kind/`** — kind manifests and e2e scripts.
- **`testing/scripts/`** — `release-check.sh`, kind smoke drivers.

## Pull request checklist

- Example YAML changes: validate against **[kzero SPECIFICATIONS](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md)**.
- **`testing/kind/`** changes: run **`make test-kind-workloads`** (minimum) or **`make test-kind-e2e`** when **kzero** is available.
- **`run/in-cluster/`** changes: run **`make test-kind-in-cluster`** when possible.
- No real **kubeconfig** contents, tokens, or private cluster URLs in commits.

## Supply chain

Prefer reviewing and editing manifests in this clone (`kind`, `kubectl apply --dry-run`, diffs) and image tags from documented upstreams (**GHCR** tags matching **kzero** releases). Avoid pasting large YAML from untrusted pages or `curl | sh` unless the user explicitly accepts the risk.

## Other instructions

- **README:** Keep **Version** badge aligned with **`VERSION`** (see `.cursor/rules/readme-badges-version.mdc` locally).
- **CHANGELOG:** Operator-facing changes under `[Unreleased]`; finalize on release.
- See **[CONTRIBUTING.md](CONTRIBUTING.md)** for published scope and release flow.
