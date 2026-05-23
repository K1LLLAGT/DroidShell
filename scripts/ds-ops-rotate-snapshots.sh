#!/usr/bin/env bash
# =============================================================================
#  ds-ops-rotate-snapshots.sh
#  Keeps only the last N snapshots.
#
#  Usage:
#    ds-ops-rotate-snapshots.sh <count>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SNAPS="$ROOT/registry"

count="${1:-5}"

ls -t "$SNAPS"/integrity.snapshot* 2>/dev/null | tail -n +$((count+1)) | xargs -r rm -f

echo "[ROTATE] Snapshots trimmed to $count"
