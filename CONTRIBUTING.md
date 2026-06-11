# Contributing (kzero-selfhosted)

## Scope

- **This repo:** Operator docs, **`run/docker/`**, **`run/examples/`**, **`run/in-cluster/`** (reference Job + RBAC), and optional **kind** e2e under **`testing/`**. Documents that **kzero** depends on external **`kubectl`** / **`helm`** for shell paths and **`release.*`**; **`run/in-cluster/`** covers **native** scale Jobs only. **No** Docker Compose or Helm chart that installs **kzero** as a long-running in-cluster controller.
- **[hrodrig/kzero](https://github.com/hrodrig/kzero):** Go application, **`make release-check`**, tests, and container images.

## Checks

- **This repo:** **`make release-check`** (VERSION, README badge, CHANGELOG section) — same gate as [CI](.github/workflows/ci.yml). Optional **`make test-kind-workloads`** (kind + manifests only) or **`make test-kind-e2e`** (includes **kzero** — see **`testing/kind/README.md`**).
- **kzero application:** clone **[hrodrig/kzero](https://github.com/hrodrig/kzero)** and run **`make release-check`** there.

## Releases

1. Work on **`develop`**; merge to **`main`** when ready.
2. Bump **`VERSION`**, **`CHANGELOG.md`**, and the README **Version** badge together.
3. On **`main`**: **`git tag -a v0.1.7 -m "Release 0.1.7"`** and **`git push origin v0.1.7`**. [**Release**](.github/workflows/release.yml) creates the GitHub Release from the matching **`CHANGELOG`** section.
4. To refresh notes for an existing tag (e.g. after a manual fix): **Actions → Release → Run workflow** with the tag name.

## Pull requests

- Keep **English** in all committed text.
- When **`run/examples/kzero.sample.yml`** changes, confirm it still matches **[docs/SPECIFICATIONS.md](https://github.com/hrodrig/kzero/blob/main/docs/SPECIFICATIONS.md)** in the **kzero** repo.
- When **`testing/kind/`** manifests or **`kzero-e2e*.yaml`** change, run **`make test-kind-workloads`** (or **`make test-kind-e2e`** if you have **kzero** installed) before merging.
- When **`run/in-cluster/`** changes, run **`make test-kind-in-cluster`** (optional **`KZERO_IN_CLUSTER_BUILD=1`** for unreleased **kzero**).

## Security

Report sensitive issues per **[SECURITY.md](SECURITY.md)**.

Community interaction: **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)**. Notable repo changes: **[CHANGELOG.md](CHANGELOG.md)**.
