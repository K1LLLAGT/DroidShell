#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell/scripts"
pattern="${1:-}"
[ -z "$pattern" ] && { echo "Usage: ds-dev-launcher.sh <pattern>"; exit 1; }
match=$(ls "$ROOT"/ds-*.sh | grep -i "$pattern" | head -1)
[ -z "$match" ] && { echo "[LAUNCH] No match"; exit 1; }
bash "$match"
