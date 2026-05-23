#!/usr/bin/env bash
# =============================================================================
#  ds-module-metadata.sh
#  Simple metadata system for modules (category, description, tags).
#
#  Usage:
#    ds-module-metadata.sh set <script> <key> <value>
#    ds-module-metadata.sh get <script> <key>
#    ds-module-metadata.sh show <script>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
META_DIR="$ROOT/registry/meta"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[META]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
err()  { echo -e "${R}[ERR]${N} $*"; exit 1; }

mkdir -p "$META_DIR"

cmd="${1:-}"; shift || true

meta_file_for() {
  local script="$1"
  local base
  base="$(basename "$script")"
  echo "$META_DIR/${base}.meta"
}

case "$cmd" in
  set)
    script="${1:-}"; key="${2:-}"; value="${3:-}"
    [[ -z "$script" || -z "$key" || -z "$value" ]] && err "Usage: set <script> <key> <value>"
    mf="$(meta_file_for "$script")"
    touch "$mf"
    # remove existing key
    grep -v "^${key}=" "$mf" 2>/dev/null > "${mf}.tmp" || true
    echo "${key}=${value}" >> "${mf}.tmp"
    mv "${mf}.tmp" "$mf"
    log "Set ${key} for $(basename "$script")"
    ;;
  get)
    script="${1:-}"; key="${2:-}"
    [[ -z "$script" || -z "$key" ]] && err "Usage: get <script> <key>"
    mf="$(meta_file_for "$script")"
    [[ -f "$mf" ]] || err "No metadata for $script"
    grep "^${key}=" "$mf" | head -1 | cut -d= -f2-
    ;;
  show)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: show <script>"
    mf="$(meta_file_for "$script")"
    [[ -f "$mf" ]] || { warn "No metadata for $script"; exit 0; }
    echo "# Metadata for $(basename "$script")"
    cat "$mf"
    ;;
  *)
    err "Usage: $0 {set|get|show} ..."
    ;;
esac
