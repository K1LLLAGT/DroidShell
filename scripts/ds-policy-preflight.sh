#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
op="${1:-}"
[ -z "$op" ] && { echo "Usage: ds-policy-preflight.sh <operation>"; exit 1; }
"$ROOT/scripts/ds-policy-invariants.sh"
echo "[PREFLIGHT] OK for $op"
