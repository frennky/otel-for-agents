# OTEL for agents

This directory provides one local OTEL stack for both Codex CLI and GitHub Copilot CLI.

The stack uses `grafana/otel-lgtm`, which bundles:

- Grafana
- Loki
- Prometheus
- Tempo
- Pyroscope
- OpenTelemetry Collector

Repo-owned configuration is shared by both agents:

- `compose.yaml` starts the LGTM container
- `otel/collector-config.yaml` defines OTLP ingest and signal routing
- `prometheus/prometheus.yml` scrapes the collector's Prometheus exporter
- `grafana/provisioning/dashboards-json/` contains the Codex and Copilot dashboards
- `scripts/` contains CLI wrappers and health checks

## Prerequisites

- Podman 5.x or newer with `podman compose`
- On macOS, a running Podman machine: `podman machine init` once, then `podman machine start`
- `curl` if you want to use `scripts/check-otel.sh`
- Codex CLI installed as `codex`
- GitHub Copilot CLI installed as `copilot`, available through `gh copilot`, or exposed through `COPILOT_BIN`

## Stack lifecycle

Start the OTEL stack:

```bash
podman compose -f compose.yaml up --wait --wait-timeout 120
```

Stop it:

```bash
podman compose -f compose.yaml down
```

Follow logs:

```bash
podman compose -f compose.yaml logs -f lgtm
```

Verify exposed services and provisioned dashboards:

```bash
./scripts/check-otel.sh
```

The Compose healthcheck uses the LGTM image's internal `/otel-lgtm/docker/healthcheck.sh` script.

## Endpoints

- Grafana: `http://127.0.0.1:3000` (`admin` / `admin`)
- Prometheus: `http://127.0.0.1:9090`
- Loki API: `http://127.0.0.1:3100`
- Tempo API: `http://127.0.0.1:3200`
- Pyroscope API: `http://127.0.0.1:4040`
- OTLP gRPC: `http://127.0.0.1:4317`
- OTLP HTTP: `http://127.0.0.1:4318`

Grafana is provisioned with the bundled LGTM datasources. The `Agents` folder includes:

- `Codex CLI Observability`
- `Copilot CLI Observability`

## Signal flow

- Codex sends logs, metrics, and traces to OTLP/gRPC on `127.0.0.1:4317`.
- Copilot sends OTLP/HTTP to `127.0.0.1:4318`.
- The shared collector sends traces to Tempo, logs to Loki, and metrics to a Prometheus scrape endpoint.
- Prometheus scrapes the collector on the internal `127.0.0.1:9464` endpoint.
- The collector also uses `spanmetrics` so Copilot trace activity can be graphed as Prometheus metrics.
- Copilot token panels use the `gen_ai.client.token.usage` OTLP metric after Prometheus name normalization.

## Codex CLI

Run Codex CLI with telemetry enabled:

```bash
./scripts/codex-cli-otel.sh
./scripts/codex-cli-otel.sh exec "summarize this repository"
```

The wrapper applies one-off Codex config overrides and does not edit `~/.codex/config.toml`.
It enables `otel.log_user_prompt=true`, so raw prompts can appear in Loki/Grafana.

Official reference:

- https://developers.openai.com/codex/config-reference

## Copilot CLI

Run Copilot CLI with telemetry enabled:

```bash
./scripts/copilot-cli-otel.sh
```

The wrapper sets these defaults:

- `OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4318`
- `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=cumulative`
- `COPILOT_OTEL_EXPORTER_TYPE=otlp-http`
- `COPILOT_OTEL_ENABLED=true`
- `OTEL_SERVICE_NAME=github-copilot`
- `COPILOT_OTEL_SOURCE_NAME=github.copilot`
- `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=false`

Official reference:

- https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference
