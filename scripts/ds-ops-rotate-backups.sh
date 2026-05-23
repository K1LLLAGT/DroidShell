#!/usr/bin/env bash
# =============================================================================
#  ds-ops-rotate-backups.sh
#  Keeps only the last N exported backups.
#
#  Usage:
#    ds-ops-rotate-backups.sh <count>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/out"

count="${1:-5}"

ls -t "$OUT"/droidshell-export-* 2>/dev/null | tail -n +$((count+1)) | xargs -r rm -f

echo "[ROTATE] Backups trimmed to $count"
