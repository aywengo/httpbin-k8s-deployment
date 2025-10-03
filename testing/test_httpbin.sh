#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: test_httpbin.sh <host>

Example:
  ./test_httpbin.sh https://httpbin.org
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

HOST=${1:-}

if [[ -z "$HOST" ]]; then
  echo "error: host is required" >&2
  usage
  exit 1
fi

failures=0

check_http_code() {
  local endpoint=$1
  local expected_code=$2
  local method=${3:-GET}
  local data=${4:-}

  local url="${HOST%/}/$endpoint"
  local response
  local tmp_body

  tmp_body=$(mktemp)

  if [[ "$method" == "POST" ]]; then
    response=$(curl -s -o "$tmp_body" -w "%{http_code}" -H 'Content-Type: application/json' -d "$data" "$url" || true)
  else
    response=$(curl -s -o "$tmp_body" -w "%{http_code}" "$url" || true)
  fi

  rm -f "$tmp_body"

  if [[ "$response" != "$expected_code" ]]; then
    echo "[FAIL] $method $url expected $expected_code got $response" >&2
    ((failures++))
  else
    echo "[PASS] $method $url returned $response"
  fi
}

check_http_code status/200 200
check_http_code delay/1 200
check_http_code anything/test 200
check_http_code post 200 POST '{"hello":"world"}'
check_http_code uuid 200

if (( failures > 0 )); then
  echo "Completed with $failures failure(s)." >&2
  exit 1
fi

echo "All checks passed."

