#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/timing.log"
script="${1:-}"; shift || true
[ -z "$script" ] && { echo "Usage: ds-obs-timing.sh <script> [args...]"; exit 1; }
start=$(date +%s)
bash "$ROOT/scripts/$script" "$@"
status=$?
end=$(date +%s)
dur=$((end-start))
echo "$(date +%Y-%m-%dT%H:%M:%S) $script status=$status duration=${dur}s" >> "$LOG"
echo "[TIMING] $script ${dur}s"
exit $status
