#!/usr/bin/env bash
set -euo pipefail

# Basic connectivity test between services
TARGETS=(controller emulator playflow)

for t in "${TARGETS[@]}"; do
  echo "checking $t..."
  if ping -c1 -W1 "$t" >/dev/null 2>&1; then
    echo "  ping ok"
  else
    echo "  ping failed"
  fi
  getent hosts "$t" || true
  echo
done