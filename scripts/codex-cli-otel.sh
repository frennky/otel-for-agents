#!/usr/bin/env bash
set -euo pipefail

collector_endpoint=${CODEX_OTEL_GRPC_ENDPOINT:-http://127.0.0.1:4317}

if ! command -v codex >/dev/null 2>&1; then
  echo "codex is not installed or not on PATH." >&2
  exit 1
fi

exec codex \
  --config 'otel.environment="local-podman"' \
  --config 'otel.log_user_prompt=true' \
  --config "otel.exporter={ \"otlp-grpc\" = { endpoint = \"$collector_endpoint\" } }" \
  --config "otel.metrics_exporter={ \"otlp-grpc\" = { endpoint = \"$collector_endpoint\" } }" \
  --config "otel.trace_exporter={ \"otlp-grpc\" = { endpoint = \"$collector_endpoint\" } }" \
  "$@"
