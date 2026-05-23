#!/usr/bin/env bash
# =============================================================================
#  ds-ops-unlock.sh
#  Removes a lock file.
#
#  Usage:
#    ds-ops-unlock.sh <name>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
LOCKS="$ROOT/registry/locks"

name="${1:-}"
[[ -z "$name" ]] && { echo "Usage: ds-ops-unlock.sh <name>"; exit 1; }

lock="$LOCKS/$name.lock"

rm -f "$lock"
echo "[UNLOCK] Removed: $name"
