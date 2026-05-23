#!/usr/bin/env bash
# DroidShell :: root/backup.sh
# Safe root-mode backup: app data, system configs, boot logs.
# Usage: backup.sh [--package <pkg>] [--system-configs] [--boot-logs] [--all]
#                  [--out <dir>] [--compress]

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; R='\033[1;31m'; N='\033[0m'

PACKAGES=(); SYS_CFG=false; BOOT_LOGS=false; ALL=false; COMPRESS=false
OUT_DIR="${HOME}/DroidShell/backups/$(date +%Y%m%d_%H%M%S)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)       PACKAGES+=("$2"); shift 2 ;;
    --system-configs) SYS_CFG=true;   shift   ;;
    --boot-logs)     BOOT_LOGS=true;  shift   ;;
    --all)           ALL=true;        shift   ;;
    --compress)      COMPRESS=true;   shift   ;;
    --out)           OUT_DIR="$2";    shift 2 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }
mkdir -p "$OUT_DIR"

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║      DroidShell Backup Utility           ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"
echo -e "${C}Output: ${OUT_DIR}${N}\n"

# ── App data backup ──────────────────────────────────────────────────────────
backup_package() {
  local pkg="$1"
  local src="/data/data/${pkg}"
  local dst="${OUT_DIR}/app_data/${pkg}"
  su -c "[[ -d '$src' ]]" 2>/dev/null || {
    echo -e "${Y}[!] Package not found: ${pkg}${N}"; return; }
  mkdir -p "$dst"
  su -c "cp -a '${src}/.' '${dst}/'" 2>&1
  # Fix ownership so Termux user can read
  chmod -R u+rX "$dst" 2>/dev/null || true
  echo -e "${G}[✓]${N} app data → ${dst}"
}

# ── System configs ────────────────────────────────────────────────────────────
backup_system_configs() {
  local dst="${OUT_DIR}/system_configs"
  mkdir -p "$dst"
  local cfg_paths=(
    "/system/build.prop"
    "/vendor/build.prop"
    "/system/etc/hosts"
    "/system/etc/init.d"
    "/system/etc/permissions"
    "/system/etc/sysconfig"
    "/data/system/packages.xml"
    "/data/system/appops.xml"
    "/data/system/users"
    "/data/misc/wifi/WifiConfigStore.xml"
    "/data/misc/bluedroid/bt_config.xml"
    "/data/adb/magisk.db"
  )
  for p in "${cfg_paths[@]}"; do
    su -c "[[ -e '$p' ]]" 2>/dev/null || { echo -e "${Y}[skip]${N} ${p}"; continue; }
    local rel="${p#/}"; local fdst="${dst}/${rel}"
    mkdir -p "$(dirname "$fdst")"
    su -c "cp -a '$p' '$fdst'" 2>&1
    echo -e "${G}[✓]${N} ${p}"
  done
  echo -e "${G}[✓]${N} system configs → ${dst}"
}

# ── Boot logs ─────────────────────────────────────────────────────────────────
backup_boot_logs() {
  local dst="${OUT_DIR}/boot_logs"
  mkdir -p "$dst"
  su -c "dmesg -T" > "${dst}/dmesg.txt" 2>&1
  su -c "logcat -b all -d" > "${dst}/logcat_all.txt" 2>&1
  su -c "cat /proc/last_kmsg 2>/dev/null || echo 'N/A'" > "${dst}/last_kmsg.txt"
  su -c "cat /sys/fs/pstore/console-ramoops-0 2>/dev/null || echo 'N/A'" \
    > "${dst}/ramoops.txt"
  echo -e "${G}[✓]${N} boot logs → ${dst}"
}

# ── All packages ──────────────────────────────────────────────────────────────
backup_all_packages() {
  while IFS= read -r pkg; do
    [[ -n "$pkg" ]] && backup_package "$pkg"
  done < <(su -c "ls /data/data" 2>/dev/null)
}

$ALL && { backup_all_packages; backup_system_configs; backup_boot_logs; }
[[ ${#PACKAGES[@]} -gt 0 ]] && for p in "${PACKAGES[@]}"; do backup_package "$p"; done
$SYS_CFG  && backup_system_configs
$BOOT_LOGS && backup_boot_logs

# ── Compress ──────────────────────────────────────────────────────────────────
if $COMPRESS; then
  archive="${OUT_DIR}.tar.gz"
  tar -czf "$archive" -C "$(dirname "$OUT_DIR")" "$(basename "$OUT_DIR")"
  rm -rf "$OUT_DIR"
  echo -e "${G}[✓]${N} Compressed → ${archive}"
  OUT_DIR="$archive"
fi

echo -e "\n${C}══ Backup complete → ${OUT_DIR} ══${N}"

# Manifest
{
  echo "# DroidShell Backup Manifest"
  echo "# Generated: $(date -Iseconds)"
  echo "# Packages : ${PACKAGES[*]:-all}"
  echo "# Sys cfgs : $SYS_CFG"
  echo "# Boot logs: $BOOT_LOGS"
} > "${OUT_DIR%/}/MANIFEST.txt" 2>/dev/null || true
