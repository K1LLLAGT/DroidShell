#!/usr/bin/env bash
# =============================================================================
#  ds-obs-history.sh
#  Run history viewer for DroidShell scripts.
#
#  Usage:
#    ds-obs-history.sh metrics
#    ds-obs-history.sh timing
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
METRICS="$ROOT/registry/metrics.log"
TIMING="$ROOT/registry/timing.log"

cmd="${1:-}"

case "$cmd" in
  metrics)
    [[ -f "$METRICS" ]] && cat "$METRICS" || echo "[HISTORY] No metrics log"
    ;;
  timing)
    [[ -f "$TIMING" ]] && cat "$TIMING" || echo "[HISTORY] No timing log"
    ;;
  *)
    echo "Usage: $0 {metrics|timing}"
    ;;
esac
