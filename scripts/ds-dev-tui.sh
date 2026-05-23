#!/usr/bin/env bash
# =============================================================================
#  ds-dev-tui.sh
#  Interactive TUI for browsing and running modules.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell/scripts"

while true; do
  clear
  echo "=== DroidShell Developer TUI ==="
  echo ""
  select f in $(ls "$ROOT"/ds-*.sh) "Exit"; do
    case "$f" in
      Exit) exit 0 ;;
      *) bash "$f"; break ;;
    esac
  done
done
