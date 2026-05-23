#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$HOME/DroidShell"

G='\033[1;32m'; Y='\033[1;33m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[DS]${N} $*"; }
warn() { echo -e "${Y}[!]${N}  $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

cd "$BASE_DIR"

run_if_present() {
  local label="$1"
  local script="$2"
  step "$label"
  [[ -x "$script" ]] && "$script" || warn "Skipping: $script"
}

run_if_present "1/5 — Ecosystem core"        "$BASE_DIR/scripts/ds-ecosystem.sh"
run_if_present "2/5 — Ecosystem bundle"      "$BASE_DIR/scripts/ds-bundle-ecosystem.sh"
run_if_present "3/5 — Services bundle"       "$BASE_DIR/scripts/ds-bundle-services.sh"
run_if_present "4/5 — Runtime bundle"        "$BASE_DIR/scripts/ds-bundle-runtime.sh"
run_if_present "5/5 — Fix-All-Four"          "$BASE_DIR/scripts/ds-fix-all-four.sh"

echo -e "${M}Fix-Everything complete${N}"
