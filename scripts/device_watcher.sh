#!/usr/bin/env bash
set -euo pipefail

CFG="/opt/dcluster/templates/device_config.yaml"

# Ensure adb server is running
adb start-server >/dev/null 2>&1 || true

echo "[watcher] Using config: $CFG"
if [[ ! -f "$CFG" ]]; then
  echo "[watcher] Config not found, sleeping..."
  sleep 3600
fi

connect_emulator() {
  local host="${1:-droid_emulator}"
  local port="${2:-5555}"
  echo "[watcher] adb connect ${host}:${port}"
  adb connect "${host}:${port}" || true
}

while true; do
  # List physical devices
  adb devices || true

  # Connect configured emulators
  if command -v yq >/dev/null 2>&1; then
    yq -r '.devices[]? | select(.type=="emulator") | "\(.host // \"droid_emulator\") \(.port // 5555)"' "$CFG" \
      | while read -r h p; do
          [[ -n "$h" && -n "$p" ]] && connect_emulator "$h" "$p"
        done
  fi

  sleep 5

done