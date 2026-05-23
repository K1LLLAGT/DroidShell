#!/usr/bin/env bash
# =============================================================================
#  ds-ops-lock.sh
#  Creates a lock file to prevent concurrent operations.
#
#  Usage:
#    ds-ops-lock.sh <name>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
LOCKS="$ROOT/registry/locks"

name="${1:-}"
[[ -z "$name" ]] && { echo "Usage: ds-ops-lock.sh <name>"; exit 1; }

lock="$LOCKS/$name.lock"

if [[ -f "$lock" ]]; then
  echo "[LOCK] Already locked: $name"
  exit 1
fi

echo $$ > "$lock"
echo "[LOCK] Created: $name"
