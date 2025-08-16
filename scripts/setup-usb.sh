#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")/../templates/udev-rules.d" && pwd)"
DEST_DIR="/etc/udev/rules.d"

echo "Copying udev rules from ${SRC_DIR} to ${DEST_DIR}" >&2
sudo cp "${SRC_DIR}"/*.rules "${DEST_DIR}/"

echo "Reloading udev rules" >&2
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "USB rules installed" >&2