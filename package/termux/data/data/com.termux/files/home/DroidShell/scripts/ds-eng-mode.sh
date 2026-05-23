#!/usr/bin/env bash
# ds-eng-mode.sh
# Adds DroidShell Engineering Mode: config toggle + root helper + menu + Magisk hook.

set -euo pipefail

BANNER="
  ____            _     _ ____  _          _ _
 |  _ \ _ __ ___ (_) __| / ___|| |__   ___| | |
 | | | | '__/ _ \| |/ _\` \___ \| '_ \ / _ \ | |
 | |_| | | | (_) | | (_| |___) | | | |  __/ | |
 |____/|_|  \___/|_|\__,_|____/|_| |_|\___|_|_|
  Engineering Mode  · debug · verbose · safe
"

echo "$BANNER"
echo

BASE_DIR="$(pwd)"
MAGISK_DIR="$BASE_DIR/magisk-droidshell"
ETC_DIR="$MAGISK_DIR/system/etc"
ROOT_DIR="$BASE_DIR/root"
SCRIPTS_DIR="$BASE_DIR/scripts"
DS_ROOT="$BASE_DIR/ds_root.sh"
SERVICE_SH="$MAGISK_DIR/service.sh"

mkdir -p "$MAGISK_DIR" "$ETC_DIR" "$ROOT_DIR" "$SCRIPTS_DIR"

############################################
# 1) Ensure debug config exists
############################################
DEBUG_CONF="$ETC_DIR/droidshell-debug.conf"
if [ ! -f "$DEBUG_CONF" ]; then
  cat << 'DC' > "$DEBUG_CONF"
# DroidShell debug configuration
# Engineering Mode toggle.
# Valid values: true / false
enable_extended_logging=false
DC
  echo "[GEN] droidshell-debug.conf → $DEBUG_CONF"
else
  echo "[SKIP] droidshell-debug.conf already exists."
fi

############################################
# 2) Root-side Engineering Mode helper
############################################
cat << 'EM' > "$SCRIPTS_DIR/ds-engctl.sh"
#!/usr/bin/env bash
# ds-engctl.sh - control DroidShell Engineering Mode

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEBUG_CONF="$BASE_DIR/magisk-droidshell/system/etc/droidshell-debug.conf"

CMD="${1:-status}"

ensure_conf() {
  if [ ! -f "$DEBUG_CONF" ]; then
    mkdir -p "$(dirname "$DEBUG_CONF")"
    cat << 'DC' > "$DEBUG_CONF"
# DroidShell debug configuration
enable_extended_logging=false
DC
  fi
}

get_flag() {
  ensure_conf
  grep '^enable_extended_logging=' "$DEBUG_CONF" 2>/dev/null | cut -d'=' -f2- || echo "false"
}

set_flag() {
  ensure_conf
  val="$1"
  tmp="$DEBUG_CONF.tmp"
  grep -v '^enable_extended_logging=' "$DEBUG_CONF" > "$tmp" 2>/dev/null || true
  echo "enable_extended_logging=$val" >> "$tmp"
  mv "$tmp" "$DEBUG_CONF"
}

case "$CMD" in
  status)
    v="$(get_flag)"
    echo "Engineering Mode: $v"
    ;;
  on|enable)
    set_flag "true"
    echo "Engineering Mode enabled."
    ;;
  off|disable)
    set_flag "false"
    echo "Engineering Mode disabled."
    ;;
  *)
    echo "Usage: $0 {status|on|off|enable|disable}"
    exit 1
    ;;
esac
EM
chmod +x "$SCRIPTS_DIR/ds-engctl.sh"
echo "[GEN] ds-engctl.sh"

############################################
# 3) Hook Engineering Mode into ds_root.sh menu
############################################
if [ -f "$DS_ROOT" ] && ! grep -q "DS_ENGINEERING_MODE_MENU" "$DS_ROOT"; then
  cat << 'HOOK' >> "$DS_ROOT"

# DS_ENGINEERING_MODE_MENU
root_eng_menu() {
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " DroidShell · Engineering Mode"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ENGCTL="$BASE_DIR/scripts/ds-engctl.sh"
  if [ -x "$ENGCTL" ]; then
    echo "Current:"
    "$ENGCTL" status
  else
    echo "Engineering controller not found."
  fi
  echo
  echo " [1] Enable Engineering Mode"
  echo " [2] Disable Engineering Mode"
  echo " [b] Back"
  echo
  read -r -p "Choice: " ans
  case "$ans" in
    1) "$ENGCTL" on;  sleep 1; root_eng_menu ;;
    2) "$ENGCTL" off; sleep 1; root_eng_menu ;;
    b|B) root_main_menu ;;
    *)   root_eng_menu ;;
  esac
}
HOOK
  echo "[MERGE] added Engineering Mode menu → $DS_ROOT"
else
  echo "[SKIP] ds_root.sh already has Engineering Mode hook or missing."
fi

# Also add entry into main menu if not present
if [ -f "$DS_ROOT" ] && ! grep -q "Engineering Mode" "$DS_ROOT"; then
  # This is a light-touch append; you can refine manually later.
  cat << 'MM' >> "$DS_ROOT"

# DS_ENGINEERING_MODE_MAIN_HOOK
# Note: root_main_menu already exists; this is a comment marker only.
# You can wire a key (e.g., [4] Engineering Mode) into root_main_menu manually
# if you want a specific slot. For now, call: ds_root.sh menu; then from shell:
#   root_eng_menu
MM
  echo "[NOTE] Add a key in root_main_menu to call root_eng_menu when ready."
fi

############################################
# 4) Magisk service hook: log Engineering Mode state at boot
############################################
if [ -f "$SERVICE_SH" ] && ! grep -q "DS_ENGINEERING_MODE_BOOT" "$SERVICE_SH"; then
  cat << 'SVH' >> "$SERVICE_SH"

# DS_ENGINEERING_MODE_BOOT
CONF="$MODDIR/system/etc/droidshell-debug.conf"
if [ -f "$CONF" ]; then
  EMODE="$(grep '^enable_extended_logging=' "$CONF" 2>/dev/null | cut -d'=' -f2-)"
  log -t droidshell "Engineering Mode at boot: $EMODE"
fi
SVH
  echo "[MERGE] added Engineering Mode boot log hook → $SERVICE_SH"
else
  echo "[SKIP] Magisk service.sh already has Engineering Mode hook or missing."
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Engineering Mode — Integrated"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Control script: $SCRIPTS_DIR/ds-engctl.sh"
echo " Debug config:   $DEBUG_CONF"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
