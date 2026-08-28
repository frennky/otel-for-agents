#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${COPILOT_BIN:-}" ]]; then
  COPILOT_CMD=("${COPILOT_BIN}")
elif command -v copilot >/dev/null 2>&1; then
  COPILOT_CMD=(copilot)
elif command -v gh >/dev/null 2>&1 && gh help copilot >/dev/null 2>&1; then
  COPILOT_CMD=(gh copilot)
else
  echo "Unable to find Copilot CLI. Install the standalone 'copilot' binary or set COPILOT_BIN." >&2
  exit 1
fi

DEFAULT_ENDPOINT="http://127.0.0.1:4318"
DEFAULT_RESOURCE_ATTRIBUTES="service.namespace=copilot-cli,deployment.environment=local"

export COPILOT_OTEL_ENABLED="${COPILOT_OTEL_ENABLED:-true}"
export COPILOT_OTEL_EXPORTER_TYPE="${COPILOT_OTEL_EXPORTER_TYPE:-otlp-http}"
export OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-$DEFAULT_ENDPOINT}"
export OTEL_EXPORTER_OTLP_PROTOCOL="${OTEL_EXPORTER_OTLP_PROTOCOL:-http/json}"
export OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE="${OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE:-cumulative}"
export OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-github-copilot}"
export COPILOT_OTEL_SOURCE_NAME="${COPILOT_OTEL_SOURCE_NAME:-github.copilot}"
export OTEL_LOG_LEVEL="${OTEL_LOG_LEVEL:-INFO}"
export OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT="${OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT:-false}"

if [[ -n "${OTEL_RESOURCE_ATTRIBUTES:-}" ]]; then
  export OTEL_RESOURCE_ATTRIBUTES="${OTEL_RESOURCE_ATTRIBUTES},${DEFAULT_RESOURCE_ATTRIBUTES}"
else
  export OTEL_RESOURCE_ATTRIBUTES="${DEFAULT_RESOURCE_ATTRIBUTES}"
fi

exec "${COPILOT_CMD[@]}" "$@"
