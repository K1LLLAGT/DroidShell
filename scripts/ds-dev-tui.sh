#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell/scripts"
while true; do
  clear
  echo "=== DroidShell TUI ==="
  select f in $(ls "$ROOT"/ds-*.sh) "Exit"; do
    case "$f" in
      Exit) exit 0;;
      *) bash "$f"; break;;
    esac
  done
done
