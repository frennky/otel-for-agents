#!/usr/bin/env bash
set -euo pipefail

MAX_ATTEMPTS=30
SLEEP_SECONDS=2

check_endpoint() {
  local name="$1"
  local url="$2"
  local attempt=1
  local status_code

  while (( attempt <= MAX_ATTEMPTS )); do
    if status_code=$(curl -sS -o /dev/null -w '%{http_code}' "$url" 2>/dev/null) && [[ "$status_code" =~ ^[23][0-9][0-9]$ ]]; then
      echo "$name: ok - HTTP $status_code"
      return 0
    fi

    if (( attempt == MAX_ATTEMPTS )); then
      if [[ -n "${status_code:-}" ]]; then
        echo "$name: failed after $MAX_ATTEMPTS attempts: HTTP $status_code - $url" >&2
      else
        echo "$name: failed after $MAX_ATTEMPTS attempts: $url" >&2
      fi
      return 1
    fi

    sleep "$SLEEP_SECONDS"
    ((attempt++))
  done
}

check_endpoint "otel-collector" "http://127.0.0.1:13133/"
check_endpoint "prometheus" "http://127.0.0.1:9090/-/ready"
check_endpoint "loki" "http://127.0.0.1:3100/ready"
check_endpoint "jaeger" "http://127.0.0.1:16686"
check_endpoint "grafana" "http://127.0.0.1:3000/api/health"

echo
echo "Collector metrics endpoint: http://127.0.0.1:9464/metrics"
echo "Grafana: http://127.0.0.1:3000"
echo "Prometheus: http://127.0.0.1:9090"
echo "Loki API: http://127.0.0.1:3100"
echo "Jaeger UI: http://127.0.0.1:16686"
