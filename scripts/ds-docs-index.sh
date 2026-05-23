#!/usr/bin/env bash
# Build docs/index-table.md listing all docs/*.md

set -euo pipefail

ROOT="$HOME/DroidShell"
DOCS="$ROOT/docs"
OUT="$DOCS/index-table.md"

echo "# Documentation Index" > "$OUT"
echo >> "$OUT"

for f in "$DOCS"/*.md; do
  base="$(basename "$f")"
  echo "- $base" >> "$OUT"
done

echo "[INDEX] Wrote $OUT"
