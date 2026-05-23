#!/usr/bin/env bash
# =============================================================================
#  ds-module-installer.sh
#  Simple module install/enable/disable system.
#
#  Usage:
#    ds-module-installer.sh list
#    ds-module-installer.sh enable <script>
#    ds-module-installer.sh disable <script>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
STATE_DIR="$ROOT/registry/state"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[INST]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
err()  { echo -e "${R}[ERR]${N} $*"; exit 1; }

mkdir -p "$STATE_DIR"

cmd="${1:-}"; shift || true

state_file_for() {
  local script="$1"
  local base
  base="$(basename "$script")"
  echo "$STATE_DIR/${base}.state"
}

case "$cmd" in
  list)
    find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | while read -r f; do
      base="$(basename "$f")"
      sf="$(state_file_for "$base")"
      state="enabled"
      [[ -f "$sf" ]] && state="$(cat "$sf")"
      printf "%-40s %s\n" "$base" "$state"
    done
    ;;
  enable)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: enable <script>"
    sf="$(state_file_for "$script")"
    echo "enabled" > "$sf"
    log "Enabled $script"
    ;;
  disable)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: disable <script>"
    sf="$(state_file_for "$script")"
    echo "disabled" > "$sf"
    log "Disabled $script"
    ;;
  *)
    err "Usage: $0 {list|enable|disable} ..."
    ;;
esac
