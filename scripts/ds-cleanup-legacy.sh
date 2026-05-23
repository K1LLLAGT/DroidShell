#!/usr/bin/env bash
# =============================================================================
#  ds-cleanup-legacy.sh
#  Removes leftover "droidshell-" references repo‑wide.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'
log()  { echo -e "${G}[CLEAN]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N}  $*"; }

cd "$ROOT"

log "Scanning for legacy references…"

grep -RIl "droidshell-" "$ROOT" | while read -r FILE; do
  log "Fixing: $FILE"
  sed -i 's/droidshell-/ds-/g' "$FILE"
done

log "Cleanup complete."
