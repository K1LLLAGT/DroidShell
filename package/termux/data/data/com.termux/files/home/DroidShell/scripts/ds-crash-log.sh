#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/crash.log"
script="${1:-}"; shift || true
[ -z "$script" ] && { echo "Usage: ds-crash-log.sh <script> [args...]"; exit 1; }
ts="$(date +%Y-%m-%dT%H:%M:%S)"
bash "$ROOT/scripts/$script" "$@"
status=$?
[ $status -ne 0 ] && echo "$ts script=$script status=$status args=\"$*\"" >> "$LOG"
exit $status
