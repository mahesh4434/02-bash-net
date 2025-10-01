#!/usr/bin/env bash
# 05_http_diag.sh - simple HTTP health check
set -euo pipefail

URL=${1:-http://localhost}
TIMEOUT=${2:-5}   # seconds
VERBOSE=false

# simple arg handling for -v (verbose)
if [ "${1:-}" == "-v" ]; then
  VERBOSE=true
  URL=${2:-http://localhost}
  TIMEOUT=${3:-5}
fi

echo "Checking: $URL (timeout ${TIMEOUT}s)"
if [ "$VERBOSE" = true ]; then
  curl -v --max-time "$TIMEOUT" "$URL"
  exit $?
else
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$URL" || echo "000")
  echo "HTTP status: $STATUS"
  # return non-zero on non-2xx
  if [[ "$STATUS" =~ ^2[0-9][0-9]$ ]]; then
    exit 0
  else
    exit 2
  fi
fi
