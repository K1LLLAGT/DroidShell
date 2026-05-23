#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
EVENTS="$ROOT/registry/events"
cmd="${1:-}"; shift || true
case "$cmd" in
  emit) ts=$(date +%Y-%m-%dT%H:%M:%S); echo "$ts $*" >> "$EVENTS/bus.log";;
  tail) tail -f "$EVENTS/bus.log";;
  *) echo "Usage: $0 {emit|tail}";;
esac
