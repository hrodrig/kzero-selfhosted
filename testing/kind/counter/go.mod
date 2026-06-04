module github.com/hrodrig/kzero-selfhosted/testing/kind/counter

// Toolchain patch is intentional: keep in sync with Dockerfile builder (stdlib/runtime CVE fixes).
go 1.26

toolchain go1.26.3

require github.com/lib/pq v1.10.9
