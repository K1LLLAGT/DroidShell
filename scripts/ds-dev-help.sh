#!/usr/bin/env bash
# =============================================================================
#  ds-dev-help.sh
#  Shows help for any module by printing its header block.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell/scripts"
script="${1:-}"

[[ -z "$script" ]] && { echo "Usage: ds-dev-help.sh <script>"; exit 1; }

file="$ROOT/$script"

[[ ! -f "$file" ]] && { echo "[HELP] Script not found"; exit 1; }

echo "=== Help: $script ==="
grep -E '^#' "$file"
