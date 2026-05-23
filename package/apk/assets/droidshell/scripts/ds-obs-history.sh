#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
METRICS="$ROOT/registry/metrics.log"
TIMING="$ROOT/registry/timing.log"
cmd="${1:-}"
case "$cmd" in
  metrics) [ -f "$METRICS" ] && cat "$METRICS" || echo "No metrics";;
  timing)  [ -f "$TIMING" ] && cat "$TIMING" || echo "No timing";;
  *) echo "Usage: $0 {metrics|timing}";;
esac
