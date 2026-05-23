#!/usr/bin/env bash
set -euo pipefail

INTERVAL_MIN="${1:-60}"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$BASE_DIR/scripts"

log() { echo "[DroidShell-Updater] $*"; }

while true; do
  log "Checking for updates (channel: stable)..."
  if [ -x "$SCRIPT_DIR/ds-ota-client.sh" ]; then
    "$SCRIPT_DIR/ds-ota-client.sh" stable || log "Update check failed."
  else
    log "ds-ota-client.sh not found."
  fi
  log "Sleeping ${INTERVAL_MIN} minutes..."
  sleep "$((INTERVAL_MIN * 60))"
done
