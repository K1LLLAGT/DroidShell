#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/telemetry.log"
cmd="${1:-}"; shift || true
case "$cmd" in
  summary)
    [ -f "$LOG" ] || { echo "No telemetry"; exit 0; }
    awk '{for(i=1;i<=NF;i++) if($i ~ /^event=/){sub("event=","",$i); print $i}}' "$LOG" | sort | uniq -c | sort -nr;;
  recent)
    n="${1:-20}"
    [ -f "$LOG" ] && tail -n "$n" "$LOG" || echo "No telemetry";;
  *) echo "Usage: $0 {summary|recent [N]}";;
esac
