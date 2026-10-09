#!/usr/bin/env bash
# Starts the mock app, runs a 30-second Locust load test against it, then stops the app.
# Usage: performance/run_perf.sh   (or: make test-perf)
set -euo pipefail

PORT=8100
USERS=20          # virtual users running at the same time
SPAWN_RATE=5      # new users started per second
DURATION="${DURATION:-30s}"

cd "$(dirname "$0")/.."
mkdir -p reports

APP_ENV=local .venv/bin/uvicorn mock_app.main:app --port "$PORT" --log-level warning &
SERVER_PID=$!
trap 'kill $SERVER_PID' EXIT

# curl keeps retrying until the app answers /health (no fixed sleep)
curl --silent --fail --retry 20 --retry-connrefused --retry-delay 1 "http://127.0.0.1:$PORT/health" > /dev/null

.venv/bin/locust -f performance/locustfile.py \
  --headless --host "http://127.0.0.1:$PORT" \
  --users "$USERS" --spawn-rate "$SPAWN_RATE" --run-time "$DURATION" \
  --html reports/performance.html --csv reports/performance
