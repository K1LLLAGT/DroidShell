#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$BASE_DIR/scripts"

pause() { printf "\nPress Enter to continue..."; read -r _; }

while true; do
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " DroidShell TUI Control Center"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " 1) Check for OTA update (stable)"
  echo " 2) Run OTA client (choose channel)"
  echo " 3) List registry packages"
  echo " 4) Open Web Console (file path hint)"
  echo " 5) Start updater daemon (foreground)"
  echo " 6) Package manager (interactive)"
  echo " 7) Exit"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  printf "Select: "
  read -r choice
  case "$choice" in
    1)
      "$SCRIPTS/ds-ota-client.sh" stable || true
      pause
      ;;
    2)
      printf "Channel (stable/beta/dev): "
      read -r ch
      "$SCRIPTS/ds-ota-client.sh" "${ch:-stable}" || true
      pause
      ;;
    3)
      "$SCRIPTS/ds-pkg.sh" list || true
      pause
      ;;
    4)
      echo "Open in browser:"
      echo "  $BASE_DIR/web/console/index.html"
      echo "  $BASE_DIR/web/console2/index.html"
      pause
      ;;
    5)
      echo "Starting updater daemon (Ctrl+C to stop)..."
      "$SCRIPTS/ds-updater-daemon.sh" 60 || true
      pause
      ;;
    6)
      echo "Registry packages:"
      "$SCRIPTS/ds-pkg.sh" list || true
      printf "\nEnter package name to install (or blank to cancel): "
      read -r name
      [ -n "$name" ] && "$SCRIPTS/ds-pkg.sh" install "$name" || true
      pause
      ;;
    7)
      exit 0
      ;;
    *)
      ;;
  esac
done
