#!/usr/bin/env bash
# DroidShell :: ds_root.sh
# Master root-enhancements entry point.
# Usage: ds_root.sh <module> [args...]

DS_ROOT="$(cd "$(dirname "$0")" && pwd)"
C='\033[1;36m'; G='\033[1;32m'; W='\033[1;37m'; N='\033[0m'

declare -A MODULES=(
  [detect]="root/detect_root.sh"
  [fileops]="root/fileops.sh"
  [apk]="root/apk_extract.sh"
  [logs]="root/log_collect.sh"
  [procs]="root/proc_inspect.sh"
  [net]="root/net_inspect.sh"
  [backup]="root/backup.sh"
  [exec]="root/shell_exec.sh"
  [partition]="root/modules/partition_ops.sh"
  [selinux]="root/modules/selinux_inspect.sh"
  [vboot]="root/modules/verified_boot.sh"
  [mkmodule]="root/modules/build_module.sh"
  [update]="root/modules/update_system.sh"
)

print_menu() {
  echo -e "${C}╔══════════════════════════════════════════════════╗${N}"
  echo -e "${C}║         DroidShell Root Enhancements             ║${N}"
  echo -e "${C}╚══════════════════════════════════════════════════╝${N}"
  echo -e "${C}Available modules:${N}"
  printf '  %-14s %s\n' \
    "detect"    "Root detection (Magisk/KernelSU/APatch/su)" \
    "fileops"   "Root-mode file operations (r/w all sys paths)" \
    "apk"       "APK extraction from /system/app + priv-app" \
    "logs"      "Log collection (logcat/dmesg/kmsg)" \
    "procs"     "Full process inspection via /proc" \
    "net"       "Network inspector (/proc/net, iptables, routes)" \
    "backup"    "Backup app data, system configs, boot logs" \
    "exec"      "Safe su -c shell executor (with audit log)" \
    "partition" "Partition list/read/flash/verify" \
    "selinux"   "SELinux policy inspection + allow-module gen" \
    "vboot"     "Verified Boot / AVB state inspector" \
    "mkmodule"  "Scaffold a new DroidShell root module" \
    "update"    "DroidShell update/rollback system"
  echo ""
  echo -e "Usage: ${W}$(basename "$0") <module> [args...]${N}"
}

MOD="${1:-help}"; shift 2>/dev/null || true

if [[ "$MOD" == "help" ]] || [[ -z "$MOD" ]]; then
  print_menu; exit 0
fi

if [[ -n "${MODULES[$MOD]:-}" ]]; then
  script="${DS_ROOT}/${MODULES[$MOD]}"
  [[ -x "$script" ]] || chmod +x "$script"
  exec bash "$script" "$@"
else
  echo -e "${C}Unknown module: ${MOD}${N}"
  print_menu
  exit 1
fi

# EXTRA_ROOT_MODULES
root_extra_menu() {
  cat << EOM
[Extra Root Modules]
  sp    - system properties
  svc   - service manager
  th    - thermal/power
  krn   - kernel params
  mnt   - mounts
  stor  - storage map
  sch   - scheduler
  mem   - memory
  fw    - firewall
  dns   - DNS
EOM
}

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

# DS_ROOT_WIDGETS_HOOK
if [ -f "\$ROOT_BASE_DIR/root/dashboard_widgets.sh" ]; then
  . "\$ROOT_BASE_DIR/root/dashboard_widgets.sh"
fi

# Override/extend root_dashboard if widgets available
if command -v ds_widget_battery >/dev/null 2>&1; then
  root_dashboard() {
    clear
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " DroidShell · Root Dashboard (widgets)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    ds_widget_battery
    ds_widget_selinux
    ds_widget_magisk
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
fi
