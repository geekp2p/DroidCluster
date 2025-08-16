#!/usr/bin/env bash
set -euo pipefail

CFG="/opt/dcluster/templates/device_config.yaml"

# รอให้ adb server พร้อม
adb start-server >/dev/null 2>&1 || true

echo "[watcher] Using config: $CFG"
if [[ ! -f "$CFG" ]]; then
  echo "[watcher] Config not found, sleeping..."
  sleep 3600
fi

# ฟังก์ชันเชื่อมต่อ emulator
connect_emulator() {
  local host="${1:-droid_emulator}"
  local port="${2:-5555}"
  echo "[watcher] adb connect ${host}:${port}"
  adb connect "${host}:${port}" || true
}

# loop เช็คและเชื่อมต่อใหม่เป็นระยะ
while true; do
  # 1) physical devices: แค่ list ไว้ (udev จะ handle)
  adb devices || true

  # 2) อ่าน emulator targets จาก YAML ด้วย yq
  if command -v yq >/dev/null 2>&1; then
    yq -r '.devices[] | select(.type=="emulator") | "\(.host // \"droid_emulator\") \(.port // 5555)"' "$CFG" \
      | while read -r h p; do
          connect_emulator "$h" "$p"
        done
  fi

  sleep 5

done