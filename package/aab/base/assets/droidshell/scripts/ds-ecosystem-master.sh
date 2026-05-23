#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

log() { echo "[DroidShell-Master] $*"; }

log "Base dir: $BASE_DIR"

run_if_present() {
  local path="$1"
  if [ -x "$path" ]; then
    log "Running: $path"
    "$path"
  else
    log "Skipping (not found or not executable): $path"
  fi
}

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 1: Core ecosystem (existing)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
run_if_present "$BASE_DIR/scripts/ds-ecosystem.sh"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 2: Ecosystem extensions bundle"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
run_if_present "$BASE_DIR/scripts/ds-bundle-ecosystem.sh"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Ecosystem master run complete"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
