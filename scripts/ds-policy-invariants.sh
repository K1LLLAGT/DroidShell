#!/usr/bin/env bash
# =============================================================================
#  ds-policy-invariants.sh
#  Checks core invariants of the DroidShell environment.
#
#  Usage:
#    ds-policy-invariants.sh
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

G='\033[1;32m'; R='\033[1;31m'; N='\033[0m'
log() { echo -e "${G}[INV]${N} $*"; }
err() { echo -e "${R}[FAIL]${N} $*"; exit 1; }

check_dir() {
  [[ -d "$1" ]] || err "Missing required directory: $1"
}

check_file() {
  [[ -f "$1" ]] || err "Missing required file: $1"
}

log "Checking invariants…"

check_dir "$ROOT/scripts"
check_dir "$ROOT/registry"
check_file "$ROOT/scripts/ds-bootstrap-all.sh"
check_file "$ROOT/scripts/ds-self-heal.sh"

log "All invariants satisfied."
