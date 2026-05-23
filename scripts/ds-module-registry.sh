#!/usr/bin/env bash
# =============================================================================
#  ds-module-registry.sh
#  Builds a registry of all ds-* scripts with basic metadata.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
REGISTRY="$ROOT/registry/modules.txt"

G='\033[1;32m'; N='\033[0m'
log() { echo -e "${G}[REG]${N} $*"; }

mkdir -p "$(dirname "$REGISTRY")"

log "Building module registry at: $REGISTRY"

{
  echo "# DroidShell Module Registry"
  echo "# Generated: $(date)"
  echo "# Format: name|path|size|mtime"
  echo ""
  find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | while read -r f; do
    name="$(basename "$f")"
    size="$(stat -c '%s' "$f" 2>/dev/null || stat -f '%z' "$f")"
    mtime="$(stat -c '%y' "$f" 2>/dev/null || stat -f '%Sm' "$f")"
    echo "${name}|${f}|${size}|${mtime}"
  done
} > "$REGISTRY"

log "Registry written."
