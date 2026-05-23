#!/usr/bin/env bash
# =============================================================================
#  ds-module-search.sh
#  Fuzzy search across module names and docs.
#
#  Usage:
#    ds-module-search.sh <pattern>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
DOCS_DIR="$ROOT/docs/modules"

G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'
log()  { echo -e "${G}[SEARCH]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }

pattern="${1:-}"
[[ -z "$pattern" ]] && { warn "Usage: $0 <pattern>"; exit 1; }

log "Searching scripts for: $pattern"
find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" -print | grep -i "$pattern" || warn "No script name matches."

if [[ -d "$DOCS_DIR" ]]; then
  log "Searching docs for: $pattern"
  grep -RIn "$pattern" "$DOCS_DIR" || warn "No doc content matches."
else
  warn "Docs directory not found: $DOCS_DIR"
fi
