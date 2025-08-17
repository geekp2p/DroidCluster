#!/usr/bin/env bash
set -e

adb start-server >/dev/null

if [[ -n "${UPSTREAM_ADB:-}" ]]; then
  adb connect "${UPSTREAM_ADB}"
fi

exec python app.py
