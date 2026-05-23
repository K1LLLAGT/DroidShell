#!/usr/bin/env bash
# DroidShell :: root/detect_root.sh
# Detects Magisk, KernelSU, APatch, and plain su availability.
# Exits 0 if root found, 1 if not.

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'

ROOT_TYPE="none"
ROOT_PATH=""
MAGISK_VER=""

detect_magisk() {
  local mgk_paths=( /sbin/.magisk/busybox /data/adb/magisk /data/adb/magisk.img
                    /data/adb/modules/.core /sbin/magisk )
  for p in "${mgk_paths[@]}"; do
    [[ -e "$p" ]] && { ROOT_TYPE="magisk"; ROOT_PATH="$p"; break; }
  done
  # Try version query
  if command -v magisk &>/dev/null; then
    MAGISK_VER="$(magisk -v 2>/dev/null || echo unknown)"
    ROOT_TYPE="magisk"
    ROOT_PATH="$(command -v magisk)"
  fi
}

detect_kernelsu() {
  [[ -e /data/adb/ksud ]] || [[ -e /sbin/ksud ]] || \
  command -v ksud &>/dev/null && { ROOT_TYPE="kernelsu"; ROOT_PATH="$(command -v ksud 2>/dev/null || echo /data/adb/ksud)"; }
}

detect_apatch() {
  [[ -e /data/adb/apatch ]] && { ROOT_TYPE="apatch"; ROOT_PATH="/data/adb/apatch"; }
}

detect_su() {
  local su_paths=( /sbin/su /system/bin/su /system/xbin/su /su/bin/su
                   /magisk/.core/bin/su /data/adb/magisk/su )
  for p in "${su_paths[@]}"; do
    [[ -x "$p" ]] && { ROOT_TYPE="su"; ROOT_PATH="$p"; return; }
  done
  command -v su &>/dev/null && { ROOT_TYPE="su"; ROOT_PATH="$(command -v su)"; }
}

detect_magisk
[[ "$ROOT_TYPE" == "none" ]] && detect_kernelsu
[[ "$ROOT_TYPE" == "none" ]] && detect_apatch
[[ "$ROOT_TYPE" == "none" ]] && detect_su

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║       DroidShell Root Detection          ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"

if [[ "$ROOT_TYPE" == "none" ]]; then
  echo -e "${Y}[!] No root mechanism detected.${N}"
  exit 1
fi

echo -e "${G}[✓] Root type   : ${W}${ROOT_TYPE}${N}"
echo -e "${G}[✓] Root path   : ${W}${ROOT_PATH}${N}"
[[ -n "$MAGISK_VER" ]] && echo -e "${G}[✓] Magisk ver  : ${W}${MAGISK_VER}${N}"

# Verify actual root by running whoami as root
if su -c "whoami" 2>/dev/null | grep -q "root"; then
  echo -e "${G}[✓] su -c exec  : ${W}confirmed root shell${N}"
else
  echo -e "${Y}[!] su -c exec  : could not verify (may need interactive grant)${N}"
fi

echo "root_type=${ROOT_TYPE}"   > /tmp/ds_root_cache
echo "root_path=${ROOT_PATH}"  >> /tmp/ds_root_cache
[[ -n "$MAGISK_VER" ]] && echo "magisk_ver=${MAGISK_VER}" >> /tmp/ds_root_cache

exit 0
