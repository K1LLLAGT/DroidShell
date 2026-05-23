#!/usr/bin/env bash
# =============================================================================
#  ds-crash-log.sh
#  Wrapper to run a script and log crashes/non-zero exits.
#
#  Usage:
#    ds-crash-log.sh <script> [args...]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/crash.log"

script="${1:-}"; shift || true
[[ -z "$script" ]] && { echo "Usage: ds-crash-log.sh <script> [args...]"; exit 1; }

ts="$(date +%Y-%m-%dT%H:%M:%S)"
bash "$ROOT/scripts/$script" "$@"
status=$?

if [[ $status -ne 0 ]]; then
  echo "$ts script=$script status=$status args=\"$*\"" >> "$LOG"
  echo "[CRASH] Logged failure for $script (status=$status)"
fi

exit $status
