#!/usr/bin/env bash
# ds-module-docs.sh
set -euo pipefail
ROOT="$HOME/DroidShell"
DOCS="$ROOT/registry/docs"
mkdir -p "$DOCS"
for f in "$ROOT"/scripts/ds-*.sh; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  out="$DOCS/$base.txt"
  grep -E '^#' "$f" > "$out" || true
done
echo "[DOCS] Docs written to: $DOCS"
