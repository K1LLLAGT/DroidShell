#!/usr/bin/env bash
# =============================================================================
#  ds-module-docs.sh
#  Auto-generates simple Markdown docs for each ds-* script.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
DOCS_DIR="$ROOT/docs/modules"

G='\033[1;32m'; N='\033[0m'
log() { echo -e "${G}[DOCS]${N} $*"; }

mkdir -p "$DOCS_DIR"

log "Generating module docs into: $DOCS_DIR"

find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | while read -r f; do
  name="$(basename "$f")"
  out="$DOCS_DIR/${name%.sh}.md"
  log "Doc: $name → $(basename "$out")"

  {
    echo "# $name"
    echo ""
    echo "Path: \`$f\`"
    echo ""
    echo "## Description"
    head -5 "$f" | sed 's/^/# /' | sed 's/^# # /- /'
    echo ""
    echo "## Usage"
    echo "\`$name\`"
  } > "$out"
done

log "Docs generation complete."
