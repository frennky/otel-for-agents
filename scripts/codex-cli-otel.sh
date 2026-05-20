#!/usr/bin/env bash
set -euo pipefail

exec codex \
  --config 'otel.environment="local-podman"' \
  --config 'otel.log_user_prompt=true' \
  --config 'otel.exporter={ "otlp-grpc" = { endpoint = "http://127.0.0.1:4317" } }' \
  --config 'otel.metrics_exporter={ "otlp-grpc" = { endpoint = "http://127.0.0.1:4317" } }' \
  --config 'otel.trace_exporter={ "otlp-grpc" = { endpoint = "http://127.0.0.1:4317" } }' \
  "$@"
