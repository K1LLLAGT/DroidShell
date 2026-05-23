#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
METRICS="$ROOT/registry/metrics.log"
cmd="${1:-}"; shift || true
case "$cmd" in
  log) script="${1:-}"; status="${2:-}"
       [ -z "$script" ] && exit 1
       echo "$(date +%Y-%m-%dT%H:%M:%S) $script $status" >> "$METRICS";;
  summary)
       [ -f "$METRICS" ] && awk '{print $2, $3}' "$METRICS" | sort | uniq -c | sort -nr || echo "No metrics";;
  *) echo "Usage: $0 {log|summary}";;
esac
