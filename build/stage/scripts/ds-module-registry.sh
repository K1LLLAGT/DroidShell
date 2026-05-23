#!/usr/bin/env bash
# ds-module-registry.sh
set -euo pipefail
ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
REG="$ROOT/registry"
META="$REG/meta"
mkdir -p "$META"
: > "$META/modules.list"
for f in "$SCRIPTS"/ds-*.sh; do
  [ -f "$f" ] || continue
  echo "$(basename "$f")" >> "$META/modules.list"
done
echo "[REGISTRY] Updated: $META/modules.list"
