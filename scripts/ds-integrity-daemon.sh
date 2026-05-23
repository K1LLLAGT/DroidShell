#!/usr/bin/env bash
# =============================================================================
#  ds-integrity-daemon.sh
#  Simple looped integrity checker (foreground daemon-style).
#
#  Usage:
#    ds-integrity-daemon.sh <interval-seconds>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
INTERVAL="${1:-300}"

[[ -f "$ROOT/registry/integrity.snapshot" ]] || {
  echo "[INTEGRITY-DAEMON] No snapshot found, creating one…"
  "$ROOT/scripts/ds-integrity-snapshot.sh"
}

echo "[INTEGRITY-DAEMON] Starting, interval=${INTERVAL}s"

while true; do
  ts=$(date +%Y-%m-%dT%H:%M:%S)
  echo "[INTEGRITY-DAEMON] [$ts] Running compare…"
  if "$ROOT/scripts/ds-integrity-compare.sh"; then
    echo "[INTEGRITY-DAEMON] OK"
  else
    echo "[INTEGRITY-DAEMON] WARNING: integrity mismatch"
  fi
  sleep "$INTERVAL"
done
