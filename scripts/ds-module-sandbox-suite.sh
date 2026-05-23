#!/usr/bin/env bash
# =============================================================================
#  ds-module-sandbox-suite.sh
#  Simple permission model for modules (allow-net, allow-root, allow-fs, allow-exec).
#
#  Usage:
#    ds-module-sandbox-suite.sh set <script> <perm> <on|off>
#    ds-module-sandbox-suite.sh show <script>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SBOX_DIR="$ROOT/registry/sandbox"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[SBOX]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
err()  { echo -e "${R}[ERR]${N} $*"; exit 1; }

mkdir -p "$SBOX_DIR"

cmd="${1:-}"; shift || true

sbox_file_for() {
  local script="$1"
  local base
  base="$(basename "$script")"
  echo "$SBOX_DIR/${base}.perm"
}

case "$cmd" in
  set)
    script="${1:-}"; perm="${2:-}"; val="${3:-}"
    [[ -z "$script" || -z "$perm" || -z "$val" ]] && err "Usage: set <script> <perm> <on|off>"
    sf="$(sbox_file_for "$script")"
    touch "$sf"
    grep -v "^${perm}=" "$sf" 2>/dev/null > "${sf}.tmp" || true
    echo "${perm}=${val}" >> "${sf}.tmp"
    mv "${sf}.tmp" "$sf"
    log "Set ${perm}=${val} for $(basename "$script")"
    ;;
  show)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: show <script>"
    sf="$(sbox_file_for "$script")"
    [[ -f "$sf" ]] || { warn "No sandbox config for $script"; exit 0; }
    echo "# Sandbox permissions for $(basename "$script")"
    cat "$sf"
    ;;
  *)
    err "Usage: $0 {set|show} ..."
    ;;
esac
