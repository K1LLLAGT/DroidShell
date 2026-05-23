#!/usr/bin/env bash
# ds-module-metadata.sh
set -euo pipefail
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
META="$REG/meta"
mkdir -p "$META"
script="${1:-}"
[ -z "$script" ] && { echo "Usage: ds-module-metadata.sh <script>"; exit 1; }
out="$META/$script.meta"
grep -E '^#' "$ROOT/scripts/$script" > "$out" || true
echo "[META] Wrote: $out"
