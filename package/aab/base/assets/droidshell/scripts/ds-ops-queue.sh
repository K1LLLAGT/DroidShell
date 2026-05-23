#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
QUEUE="$ROOT/registry/queue"
cmd="${1:-}"; shift || true
case "$cmd" in
  add) job_id="$(date +%s)-$RANDOM"; echo "$@" > "$QUEUE/$job_id.job"; echo "$job_id";;
  list) ls "$QUEUE";;
  *) echo "Usage: $0 {add|list}";;
esac
