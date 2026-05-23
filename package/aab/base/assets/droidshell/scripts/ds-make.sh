#!/usr/bin/env bash
# Make-style wrapper for common tasks

set -euo pipefail

ROOT="$HOME/DroidShell"

case "$1" in
  docs)
    bash "$ROOT/scripts/ds-docs-index.sh"
    bash "$ROOT/scripts/ds-docs-site.sh"
    echo "[MAKE] Docs built."
    ;;
  graphs)
    bash "$ROOT/scripts/ds-graphs-refresh.sh"
    echo "[MAKE] Graphs refreshed."
    ;;
  all)
    bash "$ROOT/scripts/ds-docs-index.sh"
    bash "$ROOT/scripts/ds-docs-site.sh"
    bash "$ROOT/scripts/ds-graphs-refresh.sh"
    echo "[MAKE] All tasks complete."
    ;;
  *)
    echo "Usage: ds-make.sh {docs|graphs|all}"
    exit 1
    ;;
esac
