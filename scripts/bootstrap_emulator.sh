#!/usr/bin/env bash
set -euo pipefail

ADB_SERVER_SOCKET=${ADB_SERVER_SOCKET:-tcp:5037}
ANDROID_MODE=${ANDROID_MODE:-emulator}
TARGET_HOST=${EMULATOR_HOST:-pf_emulator}
TARGET_PORT=${EMULATOR_PORT:-5555}

# Start fresh ADB server inside this container
adb kill-server >/dev/null 2>&1 || true
adb start-server

if [[ "$ANDROID_MODE" == "real" ]]; then
  if [[ -z "${DEVICE_SERIAL:-}" ]]; then
    echo "DEVICE_SERIAL must be set for real device mode"
    exit 1
  fi
  for i in {1..30}; do
    adb connect "$DEVICE_SERIAL" && break || true
    sleep 2
  done
else
  # Wait for emulator console port to open (5554)
  for i in {1..60}; do
    if nc -z "$TARGET_HOST" 5554 >/dev/null 2>&1; then
      break
    fi
    sleep 2
  done

  # Switch emulator adbd to TCP mode
  adb wait-for-device || true
  adb tcpip "$TARGET_PORT" || true
  sleep 2

  # Try to connect over TCP between containers
  for i in {1..30}; do
    adb connect "$TARGET_HOST:$TARGET_PORT" && break || true
    sleep 2
  done

  export DEVICE_SERIAL="${DEVICE_SERIAL:-${TARGET_HOST}:${TARGET_PORT}}"
fi

echo "ADB devices:"
adb devices -l

python - <<'PY'
import uiautomator2 as u2, os, time, sys
serial=os.environ.get("DEVICE_SERIAL", "")
for _ in range(30):
    try:
        d=u2.connect(serial)
        d.healthcheck()
        sys.exit(0)
    except Exception:
        time.sleep(2)
sys.exit(0)
PY

exec python /app/app.py