#!/usr/bin/env bash
# =============================================================================
#  ds-ops-event-bus.sh
#  Simple event bus for broadcasting system events.
#
#  Usage:
#    ds-ops-event-bus.sh emit <event> [data...]
#    ds-ops-event-bus.sh tail
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
EVENTS="$ROOT/registry/events"

cmd="${1:-}"; shift || true

case "$cmd" in
  emit)
    ts=$(date +%Y-%m-%dT%H:%M:%S)
    echo "$ts $*" >> "$EVENTS/bus.log"
    echo "[EVENT] $ts $*"
    ;;
  tail)
    tail -f "$EVENTS/bus.log"
    ;;
  *)
    echo "Usage: $0 {emit|tail}"
    ;;
esac
