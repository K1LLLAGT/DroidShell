#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell/scripts"
script="${1:-}"
[ -z "$script" ] && { echo "Usage: ds-dev-help.sh <script>"; exit 1; }
grep -E '^#' "$ROOT/$script" || true
