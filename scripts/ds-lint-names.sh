#!/usr/bin/env bash
# =============================================================================
#  ds-lint-names.sh
#  Verifies naming consistency across all scripts.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell/scripts"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[LINT]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N}  $*"; }
err()  { echo -e "${R}[ERR]${N}   $*"; }

cd "$ROOT"

log "Checking for legacy script names…"

BAD=$(find "$ROOT" -maxdepth 1 -type f -name "droidshell-*.sh")

if [[ -z "$BAD" ]]; then
  log "No legacy script names found."
else
  warn "Legacy scripts detected:"
  echo "$BAD"
fi

log "Checking for legacy references inside scripts…"

grep -RIn "droidshell-" "$ROOT" || log "No legacy references found."

log "Lint complete."
