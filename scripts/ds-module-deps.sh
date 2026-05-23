#!/usr/bin/env bash
# =============================================================================
#  ds-module-deps.sh
#  Builds a simple dependency graph based on script-to-script calls.
#
#  Output:
#    ~/DroidShell/registry/deps.txt
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
REG="$ROOT/registry/deps.txt"

G='\033[1;32m'; N='\033[0m'
log() { echo -e "${G}[DEPS]${N} $*"; }

mkdir -p "$(dirname "$REG")"

log "Building dependency graph at: $REG"

{
  echo "# Module Dependencies"
  echo "# from|to"
  echo "# Generated: $(date)"
  echo ""

  find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | while read -r f; do
    from="$(basename "$f")"
    # look for calls to other ds-*.sh scripts
    grep -oE 'ds-[a-zA-Z0-9_-]+\.sh' "$f" 2>/dev/null | sort -u | while read -r callee; do
      [[ "$callee" == "$from" ]] && continue
      echo "${from}|${callee}"
    done
  done
} > "$REG"

log "Dependency graph written."
