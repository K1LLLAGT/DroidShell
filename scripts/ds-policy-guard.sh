#!/usr/bin/env bash
# =============================================================================
#  ds-policy-guard.sh
#  Central guardrail checker for modules.
#
#  Usage:
#    ds-policy-guard.sh check <script>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SBOX_DIR="$ROOT/registry/sandbox"
STATE_DIR="$ROOT/registry/state"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[GUARD]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
err()  { echo -e "${R}[DENY]${N} $*"; exit 1; }

cmd="${1:-}"; shift || true

perm_file_for() {
  local script="$1"
  echo "$SBOX_DIR/$(basename "$script").perm"
}

state_file_for() {
  local script="$1"
  echo "$STATE_DIR/$(basename "$script").state"
}

case "$cmd" in
  check)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: check <script>"

    sf="$(state_file_for "$script")"
    if [[ -f "$sf" ]]; then
      state="$(cat "$sf")"
      [[ "$state" == "disabled" ]] && err "$script is disabled by policy"
    fi

    pf="$(perm_file_for "$script")"
    if [[ -f "$pf" ]]; then
      log "Permissions for $script:"
      cat "$pf"
    else
      warn "No sandbox config for $script (default allow)"
    fi
    ;;
  *)
    echo "Usage: $0 check <script>"
    ;;
esac
