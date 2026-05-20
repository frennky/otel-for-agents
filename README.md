# OTEL for agents

This directory provides local OTEL stack for both Codex CLI and GitHub Copilot CLI.

The repo is organized around stack configuration plus CLI wrappers:

- `compose.yaml` defines local observability stack
- `otel/`, `prometheus/`, `grafana/`, and `loki/` contain service-specific config
- `scripts/` contains the CLI wrapper and helper scripts

## Prerequisites

- Podman 5.x or newer with `podman compose`
- On macOS, a running Podman machine: `podman machine init` once, then `podman machine start`
- `curl` if you want to use `scripts/check-otel.sh`
- Codex CLI installed as `codex`
- GitHub Copilot CLI installed as `copilot`

## Stack lifecycle

Start the OTEL stack:

```bash
podman compose -f compose.yaml up -d
```

Stop it:

```bash
podman compose -f compose.yaml down
```

Follow logs:

```bash
podman compose -f compose.yaml logs -f otel-collector loki grafana prometheus jaeger
```

## Helper scripts

The remaining scripts add actual behavior beyond plain `podman compose`:

- `scripts/check-otel.sh`
- `scripts/codex-cli-otel.sh`
- `scripts/copilot-cli-otel.sh`

## Grafana

Grafana is provisioned with these datasources:

- `Prometheus`
- `Loki`
- `Jaeger`

The `Agents` folder includes these dashboards:

- `Codex CLI Observability`
- `Copilot CLI Observability`

## Codex CLI

Run Codex CLI with telemetry enabled:

```bash
./scripts/codex-cli-otel.sh
./scripts/codex-cli-otel.sh exec "summarize this repository"
```

Notes:

- The collector listens on `127.0.0.1:4317` for Codex OTLP gRPC export.
- Grafana includes the `Codex CLI Observability` dashboard in the `Agents` folder.

Official reference:

- https://developers.openai.com/codex/config-reference

Documented Codex OTEL config keys:

| Key | Values / default | Purpose |
|---|---|---|
| `otel.environment` | `string`, default `dev` | Environment tag attached to emitted OTEL events. |
| `otel.exporter` | `none`, `otlp-http`, `otlp-grpc` | Log exporter selection. |
| `otel.exporter.<id>.endpoint` | — | OTEL log exporter endpoint. |
| `otel.exporter.<id>.headers` | — | Static headers for OTEL log exporter requests. |
| `otel.exporter.<id>.protocol` | `binary`, `json` | OTLP/HTTP protocol for the log exporter. |
| `otel.exporter.<id>.tls.*` | — | TLS settings for the log exporter. |
| `otel.trace_exporter` | `none`, `otlp-http`, `otlp-grpc` | Trace exporter selection. |
| `otel.trace_exporter.<id>.endpoint` | — | OTEL trace exporter endpoint. |
| `otel.trace_exporter.<id>.headers` | — | Static headers for OTEL trace exporter requests. |
| `otel.trace_exporter.<id>.protocol` | `binary`, `json` | OTLP/HTTP protocol for the trace exporter. |
| `otel.trace_exporter.<id>.tls.*` | — | TLS settings for the trace exporter. |
| `otel.metrics_exporter` | `none`, `statsig`, `otlp-http`, `otlp-grpc`; default `statsig` | Metrics exporter selection. |
| `otel.log_user_prompt` | `boolean` | Export raw user prompts with OTEL logs. |

## Copilot CLI

Run Copilot CLI with telemetry enabled:

```bash
./scripts/copilot-cli-otel.sh
```

Notes:

- The collector listens on `127.0.0.1:4318` for Copilot OTLP HTTP export.
- The wrapper hardcodes `OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4318`. Other Copilot OTEL settings, like `OTEL_SERVICE_NAME` or `OTEL_RESOURCE_ATTRIBUTES`, can still be passed through the environment.
- Grafana includes the `Copilot CLI Observability` dashboard in the `Agents` folder, focused on traces and metrics.

Official reference:

- https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference

Documented Copilot OTEL environment variables:

| Variable | Default | Purpose |
|---|---|---|
| `COPILOT_OTEL_ENABLED` | `false` | Explicitly enable OTel. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | unset | OTLP endpoint URL; also auto-enables OTel. |
| `COPILOT_OTEL_EXPORTER_TYPE` | `otlp-http` | Exporter type: `otlp-http` or `file`. |
| `COPILOT_OTEL_FILE_EXPORTER_PATH` | unset | Write all signals to a JSON-lines file; also auto-enables OTel. |
| `OTEL_SERVICE_NAME` | `github-copilot` | Resource `service.name`. |
| `OTEL_RESOURCE_ATTRIBUTES` | unset | Extra resource attributes as comma-separated `key=value` pairs. |
| `COPILOT_OTEL_SOURCE_NAME` | `github.copilot` | Instrumentation scope name. |
| `OTEL_EXPORTER_OTLP_HEADERS` | unset | OTLP exporter auth or custom headers. |
| `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` | `false` | Capture full prompt/response content, tool arguments/results, and system/tool metadata. |
| `OTEL_LOG_LEVEL` | unset | OTEL diagnostic log level: `NONE`, `ERROR`, `WARN`, `INFO`, `DEBUG`, `VERBOSE`, `ALL`. |
