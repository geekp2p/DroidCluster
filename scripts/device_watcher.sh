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

  # 2) อ่าน emulator targets จาก YAML แบบง่ายๆ (ต้องการ yq จะเนี้ยบขึ้น)
  # โครงสร้าง:
  # devices:
  #   - name: emulator_1
  #     type: emulator
  #     host: droid_emulator
  #     port: 5555

  awk '
    $1=="-"{inblk=1;host="";port="";type=""}
    inblk && $1=="type:"{type=$2}
    inblk && $1=="host:"{host=$2}
    inblk && $1=="port:"{port=$2}
    inblk && NF==0{
      if(type=="emulator" && host!=""){
        if(port==""){port="5555"}
        printf "%s %s\n", host, port
      }
      inblk=0
    }
    END{
      if(inblk && type=="emulator" && host!=""){
        if(port==""){port="5555"}
        printf "%s %s\n", host, port
      }
    }' "$CFG" | while read -r h p; do
      connect_emulator "$h" "$p"
    done

  sleep 5
done
