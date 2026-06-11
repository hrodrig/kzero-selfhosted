# kzero-selfhosted — operator docs + optional kind e2e.

.DEFAULT_GOAL := help

.PHONY: help release-check test-kind-workloads test-kind-e2e test-kind-in-cluster

help:
	@echo "kzero-selfhosted — make targets"
	@echo ""
	@echo "  make release-check         VERSION, README badge, CHANGELOG section (pre-tag)."
	@echo "  make test-kind-workloads   kind + sample Deploy/STS/DS (no kzero binary)."
	@echo "  make test-kind-e2e         full smoke: build counter image, kind load, workloads + kzero phases 1–4 (see testing/kind/README.md)."
	@echo "                             Requires: docker, kind, kubectl, kzero (PATH or KZERO_BIN)."
	@echo "  make test-kind-in-cluster   kzero Jobs inside kind (analyze/down/up); no host kzero binary."
	@echo "                             See testing/kind/in-cluster/README.md."
	@echo ""
	@echo "  Application tests: clone https://github.com/hrodrig/kzero and run make release-check"
	@echo ""

release-check:
	@chmod +x testing/scripts/release-check.sh
	@testing/scripts/release-check.sh

test-kind-workloads:
	@chmod +x testing/scripts/kzero-kind-e2e.sh
	@KZERO_KIND_E2E_KZERO=0 testing/scripts/kzero-kind-e2e.sh

test-kind-e2e:
	@chmod +x testing/scripts/kzero-kind-e2e.sh testing/kind/scripts/pg-wipe-e2e.sh
	@testing/scripts/kzero-kind-e2e.sh

test-kind-in-cluster:
	@chmod +x testing/scripts/kzero-in-cluster-kind-smoke.sh
	@testing/scripts/kzero-in-cluster-kind-smoke.sh
