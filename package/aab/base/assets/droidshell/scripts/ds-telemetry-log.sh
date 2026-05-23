#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/telemetry.log"
event="${1:-}"; shift || true
[ -z "$event" ] && { echo "Usage: ds-telemetry-log.sh <event> [key=value ...]"; exit 1; }
echo "$(date +%Y-%m-%dT%H:%M:%S) event=$event $*" >> "$LOG"
