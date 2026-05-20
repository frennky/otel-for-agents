#!/usr/bin/env bash
set -euo pipefail

exec env OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4318 copilot "$@"
