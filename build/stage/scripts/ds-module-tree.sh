#!/usr/bin/env bash
# ds-module-tree.sh
set -euo pipefail
ROOT="$HOME/DroidShell"
OUT="$ROOT/droidshell-tree.txt"
cd "$ROOT"
find . -maxdepth 4 -print | sort > "$OUT"
echo "[TREE] Wrote: $OUT"
