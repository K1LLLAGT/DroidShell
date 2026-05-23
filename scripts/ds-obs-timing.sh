#!/usr/bin/env bash
# =============================================================================
#  ds-obs-timing.sh
#  Time wrapper for any ds-* script.
#
#  Usage:
#    ds-obs-timing.sh <script> [args...]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/timing.log"

script="${1:-}"
shift || true

[[ -z "$script" ]] && { echo "Usage: ds-obs-timing.sh <script> [args...]"; exit 1; }

start=$(date +%s)
bash "$HOME/DroidShell/scripts/$script" "$@"
status=$?
end=$(date +%s)
dur=$((end - start))

echo "$(date +%Y-%m-%dT%H:%M:%S) ${script} status=${status} duration=${dur}s" >> "$LOG"
echo "[TIMING] ${script} took ${dur}s (status=${status})"
exit $status
