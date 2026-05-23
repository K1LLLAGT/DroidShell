#!/usr/bin/env bash
# =============================================================================
#  ds-obs-metrics.sh
#  Simple metrics logger for script runs.
#
#  Usage:
#    ds-obs-metrics.sh log <script> <status>
#    ds-obs-metrics.sh summary
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
METRICS="$ROOT/registry/metrics.log"

G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'
log()  { echo -e "${G}[METRICS]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }

cmd="${1:-}"; shift || true

case "$cmd" in
  log)
    script="${1:-}"; status="${2:-}"
    [[ -z "$script" || -z "$status" ]] && { warn "Usage: log <script> <status>"; exit 1; }
    echo "$(date +%Y-%m-%dT%H:%M:%S) ${script} ${status}" >> "$METRICS"
    ;;
  summary)
    [[ -f "$METRICS" ]] || { warn "No metrics yet"; exit 0; }
    echo "=== Metrics Summary ==="
    awk '{print $2, $3}' "$METRICS" | sort | uniq -c | sort -nr
    ;;
  *)
    echo "Usage: $0 {log|summary} ..."
    ;;
esac
