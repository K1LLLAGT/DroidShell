#!/usr/bin/env bash
# Simple TUI to view module graph ASCII and DOT info.

set -euo pipefail

ROOT="$HOME/DroidShell"
GRAPH_DIR="$ROOT/registry/graphs"
ASCII="$GRAPH_DIR/modules-graph.txt"
DOT="$GRAPH_DIR/modules-graph.dot"

if [ ! -f "$ASCII" ] || [ ! -f "$DOT" ]; then
  echo "[GRAPH-TUI] Graph not found, regenerating..."
  bash "$ROOT/scripts/ds-graphs-refresh.sh"
fi

while true; do
  clear
  echo "DroidShell Module Graph TUI"
  echo "1) View ASCII graph"
  echo "2) View DOT file"
  echo "3) Regenerate graph"
  echo "4) Quit"
  echo
  printf "Choice: "
  read -r choice
  case "$choice" in
    1)
      clear
      echo "ASCII Graph:"
      echo "------------"
      cat "$ASCII"
      echo
      read -r -p "Press Enter to return..." _
      ;;
    2)
      clear
      echo "DOT Graph:"
      echo "----------"
      cat "$DOT"
      echo
      read -r -p "Press Enter to return..." _
      ;;
    3)
      bash "$ROOT/scripts/ds-graphs-refresh.sh"
      read -r -p "Regenerated. Press Enter..." _
      ;;
    4)
      exit 0
      ;;
    *)
      ;;
  esac
done
