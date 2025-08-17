#!/usr/bin/env bash
# start-emulator.sh

set -e

# ค่าพารามิเตอร์สำหรับโหมด software (เมื่อไม่มี KVM)
FALLBACK_PARAMS="-noaudio -gpu swiftshader_indirect -accel off"

# เช็กว่าซีพียูรองรับ VT-x/AMD‑V หรือไม่
if ! grep -E 'vmx|svm' /proc/cpuinfo >/dev/null; then
  echo "CPU ไม่รองรับ Virtualization หรือถูกปิดอยู่ -> ใช้โหมด software"
  EMULATOR_PARAMS="$FALLBACK_PARAMS" docker compose up "$@"
  exit 0
fi

# โหลดโมดูล KVM
if grep -q GenuineIntel /proc/cpuinfo; then
  MOD=kvm_intel
else
  MOD=kvm_amd
fi

sudo modprobe kvm || true
sudo modprobe "$MOD" || true

# ถ้ามี /dev/kvm ให้ใช้ hardware acceleration
if [ -e /dev/kvm ]; then
  echo "พบ /dev/kvm -> ใช้ Hardware acceleration"
  docker compose up "$@"
else
  echo "ไม่พบ /dev/kvm -> ใช้โหมด software"
  EMULATOR_PARAMS="$FALLBACK_PARAMS" docker compose up "$@"
fi
