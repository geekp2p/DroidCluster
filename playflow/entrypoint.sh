#!/usr/bin/env bash
set -e

adb start-server >/dev/null

# Connect to an upstream ADB server when provided. If no explicit
# upstream is configured, fall back to the emulator host/port so that
# `adb devices` inside the container sees the emulator by default.
if [[ -n "${UPSTREAM_ADB:-}" ]]; then
  adb connect "${UPSTREAM_ADB}"
elif [[ "${ANDROID_MODE:-}" == "emulator" && -n "${EMULATOR_HOST:-}" ]]; then
  adb connect "${EMULATOR_HOST}:${EMULATOR_PORT:-5555}"
fi

exec python app.py