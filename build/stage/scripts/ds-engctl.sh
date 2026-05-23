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
