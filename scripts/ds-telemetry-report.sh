#!/usr/bin/env bash
# =============================================================================
#  ds-telemetry-report.sh
#  Simple telemetry reporter (event counts, recent events).
#
#  Usage:
#    ds-telemetry-report.sh summary
#    ds-telemetry-report.sh recent [N]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/telemetry.log"

cmd="${1:-}"; shift || true

case "$cmd" in
  summary)
    [[ -f "$LOG" ]] || { echo "[TELEMETRY] No telemetry log"; exit 0; }
    echo "=== Telemetry Event Counts ==="
    awk '{for(i=1;i<=NF;i++) if($i ~ /^event=/){sub("event=","",$i); print $i}}' "$LOG" \
      | sort | uniq -c | sort -nr
    ;;
  recent)
    n="${1:-20}"
    [[ -f "$LOG" ]] || { echo "[TELEMETRY] No telemetry log"; exit 0; }
    echo "=== Last $n Telemetry Events ==="
    tail -n "$n" "$LOG"
    ;;
  *)
    echo "Usage: $0 {summary|recent [N]}"
    ;;
esac
