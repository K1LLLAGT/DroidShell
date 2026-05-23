#!/usr/bin/env bash
# Simple dashboard TUI for DroidShell.

set -euo pipefail

ROOT="$HOME/DroidShell"

count_modules() {
  ls "$ROOT"/scripts/ds-*.sh 2>/dev/null | wc -l
}

count_docs() {
  find "$ROOT/docs" -maxdepth 2 -type f -name "*.md" 2>/dev/null | wc -l
}

while true; do
  clear
  echo "DroidShell Dashboard"
  echo "--------------------"
  echo "Modules:      $(count_modules)"
  echo "Docs files:   $(count_docs)"
  echo
  echo "1) Build docs (ds-make.sh docs)"
  echo "2) Refresh graphs (ds-make.sh graphs)"
  echo "3) Build all (ds-make.sh all)"
  echo "4) View module graph TUI"
  echo "5) Search docs"
  echo "6) Quit"
  echo
  printf "Choice: "
  read -r choice
  case "$choice" in
    1) bash "$ROOT/scripts/ds-make.sh" docs; read -r -p "Done. Enter..." _ ;;
    2) bash "$ROOT/scripts/ds-make.sh" graphs; read -r -p "Done. Enter..." _ ;;
    3) bash "$ROOT/scripts/ds-make.sh" all; read -r -p "Done. Enter..." _ ;;
    4) bash "$ROOT/scripts/ds-graph-tui.sh" ;;
    5)
       printf "Search term: "
       read -r term
       bash "$ROOT/scripts/ds-docs-search.sh" "$term"
       read -r -p "Done. Enter..." _
       ;;
    6) exit 0 ;;
    *) ;;
  esac
done
