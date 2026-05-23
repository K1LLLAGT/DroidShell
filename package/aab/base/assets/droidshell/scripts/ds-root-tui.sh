#!/usr/bin/env bash
set -euo pipefail

ROOT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DS_ROOT="$ROOT_BASE_DIR/ds_root.sh"

if ! command -v dialog >/dev/null 2>&1; then
  echo "[!] dialog not installed. Install: pkg install dialog"
  exit 1
fi

main_menu() {
  CHOICE=$(dialog --clear --stdout \
    --backtitle "DroidShell Root TUI" \
    --title "Root Console" \
    --menu "Select action:" 15 60 6 \
      1 "Dashboard" \
      2 "Core tools" \
      3 "Extra modules" \
      4 "Module manager" \
      5 "JSON API info" \
      0 "Quit")
  case "$CHOICE" in
    1) "$DS_ROOT" menu ;;   # uses existing menu path
    2) "$DS_ROOT" menu ;;
    3) "$DS_ROOT" menu ;;
    4) "$ROOT_BASE_DIR/scripts/ds-root-module-manager.sh" ;;
    5) "$ROOT_BASE_DIR/scripts/ds-root-api.sh" info ;;
    0) clear; exit 0 ;;
    *) main_menu ;;
  esac
}

main_menu
