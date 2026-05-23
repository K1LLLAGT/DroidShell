#!/usr/bin/env bash
# =============================================================================
#  ds-policy-preflight.sh
#  Preflight checker before running critical operations.
#
#  Usage:
#    ds-policy-preflight.sh <operation>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

op="${1:-}"

[[ -z "$op" ]] && { echo "Usage: ds-policy-preflight.sh <operation>"; exit 1; }

echo "[PREFLIGHT] Operation: $op"

bash "$ROOT/scripts/ds-policy-invariants.sh"

case "$op" in
  release)
    [[ -f "$ROOT/VERSION" ]] || { echo "[PREFLIGHT] Missing VERSION"; exit 1; }
    ;;
  bootstrap|fix|heal)
    ;;
  *)
    ;;
esac

echo "[PREFLIGHT] OK"
