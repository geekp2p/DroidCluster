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
  local delay=2
  for attempt in 1 2 3; do
    echo "[watcher] adb connect ${host}:${port} (attempt ${attempt})"
    if adb connect "${host}:${port}" >/dev/null 2>&1; then
      echo "[watcher] connected ${host}:${port}"
      return 0
    fi
    echo "[watcher] connect failed, retrying in ${delay}s"
    sleep $delay
    delay=$((delay*2))
  done
  echo "[watcher] failed to connect ${host}:${port}"
}

while true; do
  # List physical devices
  adb devices || true

  # Connect configured emulators
  if command -v yq >/dev/null 2>&1; then
    if ! yq -e '.devices' "$CFG" >/dev/null 2>&1; then
      echo "[watcher] No devices in $CFG"
    else
      yq -r '.devices[]? | select(.type=="emulator") | "\(.host // \"droid_emulator\") \(.port // 5555)"' "$CFG" \
        | sort -u \
        | while read -r h p; do
            [[ -n "$h" && -n "$p" ]] && connect_emulator "$h" "$p"
          done
    fi
  fi

  sleep 5
done