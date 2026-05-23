#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Fix-Everything
#  ds-fix-everything.sh
#
#  Runs, in order:
#    1. ds-ecosystem.sh
#    2. ds-bundle-ecosystem.sh
#    3. ds-bundle-services.sh
#    4. ds-bundle-runtime.sh
#    5. ds-fix-all-four.sh
# =============================================================================

set -euo pipefail

BASE_DIR="$HOME/DroidShell"
cd "$BASE_DIR"

G='\033[1;32m'; Y='\033[1;33m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[DS]${N} $*"; }
warn() { echo -e "${Y}[!]${N}  $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

run_if_present() {
  local label="$1"
  local script_path="$2"

  step "$label"
  if [[ -x "$script_path" ]]; then
    log "Running: $script_path"
    "$script_path"
  else
    warn "Skipping (not found or not executable): $script_path"
  fi
}

run_if_present "1/5 — Ecosystem core"        "$BASE_DIR/scripts/ds-ecosystem.sh"
run_if_present "2/5 — Ecosystem bundle"      "$BASE_DIR/scripts/ds-bundle-ecosystem.sh"
run_if_present "3/5 — Services bundle"       "$BASE_DIR/scripts/ds-bundle-services.sh"
run_if_present "4/5 — Runtime bundle"        "$BASE_DIR/scripts/ds-bundle-runtime.sh"
run_if_present "5/5 — Fix-All-Four"          "$BASE_DIR/scripts/ds-fix-all-four.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} ds-fix-everything.sh — COMPLETE${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
