#!/usr/bin/env bash
# ds-root-integration.sh
# Integrates root menu, dashboard UI, module auto-loader, and Magisk module skeleton.

set -euo pipefail

BANNER="
  ____            _     _ ____  _          _ _
 |  _ \ _ __ ___ (_) __| / ___|| |__   ___| | |
 | | | | '__/ _ \| |/ _\` \___ \| '_ \ / _ \ | |
 | |_| | | | (_) | | (_| |___) | | | |  __/ | |
 |____/|_|  \___/|_|\__,_|____/|_| |_|\___|_|_|
  Root Integration  ·  menu · dashboard · autoload · Magisk
"

echo "$BANNER"
echo
echo "Targets:"
echo "  • /sdcard/Documents/DroidShell"
echo "  • $HOME/DroidShell"
echo

TARGETS=(
  "/sdcard/Documents/DroidShell"
  "$HOME/DroidShell"
)

for BASE in "${TARGETS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " Integrating in: $BASE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  ROOT_DIR="$BASE/root"
  MOD_DIR="$ROOT_DIR/modules"
  DS_ROOT="$BASE/ds_root.sh"

  mkdir -p "$MOD_DIR"

  if [ ! -f "$DS_ROOT" ]; then
    echo "[WARN] ds_root.sh not found at $DS_ROOT, creating minimal shell..."
    cat << 'MIN' > "$DS_ROOT"
#!/usr/bin/env bash
set -euo pipefail
MIN
    chmod +x "$DS_ROOT"
  fi

  ############################################
  # Append integrated menu + dashboard + autoloader
  ############################################
  if ! grep -q "DS_ROOT_INTEGRATED_MENU" "$DS_ROOT"; then
    cat << 'APPEND' >> "$DS_ROOT"

# DS_ROOT_INTEGRATED_MENU

ROOT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_MOD_DIR="$ROOT_BASE_DIR/root/modules"

root_autoload_modules() {
  if [ -d "$ROOT_MOD_DIR" ]; then
    for f in "$ROOT_MOD_DIR"/*.sh; do
      [ -f "$f" ] && . "$f"
    done
  fi
}

root_dashboard() {
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " DroidShell · Root Dashboard"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo " Device:"
  su -c "getprop ro.product.manufacturer 2>/dev/null" | sed 's/^/  OEM: /'
  su -c "getprop ro.product.model 2>/dev/null" | sed 's/^/  Model: /'
  su -c "getprop ro.build.version.release 2>/dev/null" | sed 's/^/  Android: /'
  echo
  echo " Root:"
  if command -v su >/dev/null 2>&1; then
    echo "  su: available"
  else
    echo "  su: NOT available"
  fi
  echo
  echo " Storage:"
  su -c "df -h /data 2>/dev/null" | sed 's/^/  /'
  echo
  echo " Network:"
  su -c "ip addr show 2>/dev/null | head -n 20" | sed 's/^/  /'
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " [m] Main menu   [q] Quit"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  read -r -p "Choice: " ans
  case "$ans" in
    m|M) root_main_menu ;;
    q|Q) exit 0 ;;
    *) root_dashboard ;;
  esac
}

root_main_menu() {
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " DroidShell · Root Console"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo " [1] Dashboard"
  echo " [2] Core tools"
  echo " [3] Extra modules"
  echo " [q] Quit"
  echo
  read -r -p "Choice: " ans
  case "$ans" in
    1) root_dashboard ;;
    2) root_core_menu ;;
    3) root_extra_menu 2>/dev/null || echo 'Extra menu not defined.' ;;
    q|Q) exit 0 ;;
    *) root_main_menu ;;
  esac
}

root_core_menu() {
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " Root Core Tools"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  det   - detect_root.sh"
  echo "  fops  - fileops.sh"
  echo "  apk   - apk_extract.sh"
  echo "  logs  - log_collect.sh"
  echo "  procs - proc_inspect.sh"
  echo "  net   - net_inspect.sh"
  echo "  bkp   - backup.sh"
  echo "  exec  - shell_exec.sh"
  echo "  part  - modules/partition_ops.sh"
  echo "  se    - modules/selinux_inspect.sh"
  echo "  vboot - modules/verified_boot.sh"
  echo "  mkmod - modules/build_module.sh"
  echo "  upd   - modules/update_system.sh"
  echo "  back  - back to main"
  echo
  read -r -p "Tool: " t
  case "$t" in
    det)   "$ROOT_BASE_DIR/root/detect_root.sh" ;;
    fops)  "$ROOT_BASE_DIR/root/fileops.sh" ;;
    apk)   "$ROOT_BASE_DIR/root/apk_extract.sh" ;;
    logs)  "$ROOT_BASE_DIR/root/log_collect.sh" ;;
    procs) "$ROOT_BASE_DIR/root/proc_inspect.sh" ;;
    net)   "$ROOT_BASE_DIR/root/net_inspect.sh" ;;
    bkp)   "$ROOT_BASE_DIR/root/backup.sh" ;;
    exec)  "$ROOT_BASE_DIR/root/shell_exec.sh" ;;
    part)  "$ROOT_BASE_DIR/root/modules/partition_ops.sh" ;;
    se)    "$ROOT_BASE_DIR/root/modules/selinux_inspect.sh" ;;
    vboot) "$ROOT_BASE_DIR/root/modules/verified_boot.sh" ;;
    mkmod) "$ROOT_BASE_DIR/root/modules/build_module.sh" ;;
    upd)   "$ROOT_BASE_DIR/root/modules/update_system.sh" ;;
    back)  root_main_menu ;;
    *)     root_core_menu ;;
  esac
}

if [ "${1:-}" = "menu" ]; then
  root_autoload_modules
  root_main_menu
fi
APPEND
    echo "[MERGE] integrated menu + dashboard + autoloader → $DS_ROOT"
  else
    echo "[SKIP] ds_root.sh already has integrated menu marker."
  fi

  ############################################
  # Magisk module skeleton
  ############################################
  MAGISK_DIR="$BASE/magisk-droidshell"
  mkdir -p "$MAGISK_DIR"

  cat << 'MM' > "$MAGISK_DIR/module.prop"
id=droidshell
name=DroidShell Root Tools
version=1.0.0
versionCode=1
author=Greg
description=DroidShell root toolkit integration as a Magisk module.
MM

  cat << 'MM' > "$MAGISK_DIR/service.sh"
#!/system/bin/sh
MODDIR=\${0%/*}
# Example: ensure a marker or log
log -t droidshell "DroidShell Magisk module loaded: \$MODDIR"
MM
  chmod +x "$MAGISK_DIR/service.sh"

  cat << 'MM' > "$MAGISK_DIR/post-fs-data.sh"
#!/system/bin/sh
# Reserved for future root setup logic.
MM
  chmod +x "$MAGISK_DIR/post-fs-data.sh"

  echo "[GEN] Magisk module skeleton → $MAGISK_DIR"

  echo "✓ Integration complete for $BASE"
done

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Root Integration — Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
