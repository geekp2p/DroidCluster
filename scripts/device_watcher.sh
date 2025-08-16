#!/usr/bin/env bash
set -euo pipefail

CFG="/opt/dcluster/templates/device_config.yaml"
warned_no_devices=0
declare -A suppress_until
last_count=-1

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
  local max_delay=30
  for attempt in 1 2 3; do
    echo "[watcher] adb connect ${host}:${port} (attempt ${attempt})"
    if adb connect "${host}:${port}" >/dev/null 2>&1; then
      echo "[watcher] connected ${host}:${port}"
      return 0
    fi
    echo "[watcher] connect failed, retrying in ${delay}s"
    sleep $delay
    delay=$((delay*2))
    if (( delay > max_delay )); then delay=$max_delay; fi
  done
  echo "[watcher] failed to connect ${host}:${port}"
  return 1
}

while true; do
  current=$(adb devices 2>/dev/null | tail -n +2 | grep -v '^$' | wc -l || true)
  if [[ "$current" != "$last_count" ]]; then
    echo "[watcher] devices=${current}"
    last_count="$current"
  fi

  if command -v yq >/dev/null 2>&1; then
    if ! yq -e '.devices' "$CFG" >/dev/null 2>&1; then
      if (( ! warned_no_devices )); then
        echo "[watcher] No devices in $CFG"
        warned_no_devices=1
      fi
    else
      warned_no_devices=0
      now=$(date +%s)
      # Connect configured emulators
      yq -r '.devices[]? | select(.type=="emulator") | "\(.host // "") \(.port // "")"' "$CFG" \
        | sort -u \
        | while read -r h p; do
            [[ -z "$h" ]] && h="droid_emulator"
            [[ -z "$p" ]] && p=5555
            key="${h}:${p}"
            if [[ ${suppress_until[$key]:-0} -gt $now ]]; then
              continue
            fi
            if connect_emulator "$h" "$p"; then
              suppress_until[$key]=$((now+15))
            fi
          done
      # Wait for specified physical devices
      yq -r '.devices[]? | select(.type=="physical") | .serial // ""' "$CFG" \
        | while read -r serial; do
            [[ -z "$serial" ]] && continue
            adb -s "$serial" wait-for-device >/dev/null 2>&1 || true
          done
    fi
  fi

  sleep 5

done