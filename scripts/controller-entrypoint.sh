#!/usr/bin/env bash
set -euo pipefail

# Ensure ADB server socket is set
export ADB_SERVER_SOCKET="${ADB_SERVER_SOCKET:-tcp:5037}"

echo "[entrypoint] Starting ADB server on ${ADB_SERVER_SOCKET}"
adb kill-server || true
adb start-server

"/opt/dcluster/scripts/wait-for-adb.sh" 127.0.0.1 5037

echo "[entrypoint] Reloading udev rules"
if command -v service >/dev/null 2>&1; then
  service udev restart || true
else
  udevadm control --reload-rules || true
fi

echo "[entrypoint] Launching device watcher"
exec /opt/dcluster/scripts/device_watcher.sh