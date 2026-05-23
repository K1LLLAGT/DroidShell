#!/usr/bin/env bash
# DroidShell :: root/modules/verified_boot.sh
# Inspect Android Verified Boot (AVB) state, vbmeta, and dm-verity.

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║   DroidShell Verified Boot Inspector     ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"

_prop() { su -c "getprop '$1' 2>/dev/null" || echo "N/A"; }

echo -e "\n${C}── AVB Properties ──────────────────────────${N}"
for p in ro.boot.verifiedbootstate ro.boot.veritymode \
          ro.boot.flash.locked ro.boot.avb_version \
          ro.boot.vbmeta.digest ro.boot.vbmeta.size \
          ro.boot.vbmeta.device ro.boot.vbmeta.flags; do
  printf '  %-40s %s\n' "$p" "$(_prop "$p")"
done

echo -e "\n${C}── dm-verity status ────────────────────────${N}"
su -c "cat /proc/fs/ext4/*/verity_mode 2>/dev/null || echo 'N/A (or not ext4)'"
su -c "dmsetup status 2>/dev/null | grep -i verity || echo 'No verity targets'"

echo -e "\n${C}── vbmeta partition (first 4k) ─────────────${N}"
vbmeta_dev=$(su -c "find /dev/block/by-name -name 'vbmeta*' 2>/dev/null" | head -1)
if [[ -n "$vbmeta_dev" ]]; then
  echo "Device: $vbmeta_dev"
  su -c "dd if='${vbmeta_dev}' bs=512 count=8 2>/dev/null | xxd | head -40"
else
  echo "vbmeta partition not found"
fi

echo -e "\n${C}── Boot partition hash ─────────────────────${N}"
boot_dev=$(su -c "find /dev/block/by-name -name 'boot' 2>/dev/null" | head -1)
if [[ -n "$boot_dev" ]]; then
  echo "Hashing first 1M of ${boot_dev}..."
  su -c "dd if='${boot_dev}' bs=1M count=1 2>/dev/null | sha256sum"
else
  echo "boot partition not found"
fi
