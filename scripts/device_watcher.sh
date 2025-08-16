#!/usr/bin/env bash
set -euo pipefail

CFG="/opt/dcluster/templates/device_config.yaml"
warned_no_devices=0
declare -A suppress
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
      yq -r '.devices[]? | select(.type=="emulator") | "\(.host // "") \(.port // "")"' "$CFG" \
        | sort -u \
        | while read -r h p; do
            [[ -z "$h" ]] && h="droid_emulator"
            [[ -z "$p" ]] && p=5555
            key="${h}:${p}"
            if [[ ${suppress[$key]:-0} -gt 0 ]]; then
              suppress[$key]=$((suppress[$key]-1))
              continue
            fi
            if connect_emulator "$h" "$p"; then
              suppress[$key]=3
            fi
          done
    fi
  fi

  sleep 5
done