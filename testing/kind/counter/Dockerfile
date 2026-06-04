# Build: from repo root — docker build -t kzero-e2e-counter:e2e -f testing/kind/counter/Dockerfile testing/kind/counter
# Builder image: stay on a current patch release (e.g. 1.26.3) to pick up std/runtime fixes for recent CVE advisories.
FROM golang:1.26.3-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY main.go ./
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /counter .

FROM alpine:3.19
RUN apk add --no-cache ca-certificates
COPY --from=build /counter /counter
USER 65534:65534
EXPOSE 8080
ENTRYPOINT ["/counter"]
