#!/usr/bin/env bash
set -euo pipefail
host="${1:-127.0.0.1}"
port="${2:-5037}"
for i in {1..30}; do
  if nc -z "$host" "$port" >/dev/null 2>&1; then
    exit 0
  fi
  sleep 1
done
echo "adb not ready on ${host}:${port}" >&2
exit 1