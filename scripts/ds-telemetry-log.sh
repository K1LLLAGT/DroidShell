#!/usr/bin/env bash
# =============================================================================
#  ds-telemetry-log.sh
#  Central telemetry logger for arbitrary key/value events.
#
#  Usage:
#    ds-telemetry-log.sh <event> [key=value ...]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/telemetry.log"

event="${1:-}"; shift || true
[[ -z "$event" ]] && { echo "Usage: ds-telemetry-log.sh <event> [key=value ...]"; exit 1; }

ts="$(date +%Y-%m-%dT%H:%M:%S)"
echo "$ts event=$event $*" >> "$LOG"
echo "[TELEMETRY] $ts event=$event $*"
