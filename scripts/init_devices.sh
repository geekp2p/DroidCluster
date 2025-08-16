#!/usr/bin/env bash
set -euo pipefail

# List devices via controller container
docker compose exec controller adb devices