#!/usr/bin/env bash
# =============================================================================
#  ds-bootstrap-all.sh
#  Rebuilds the entire DroidShell environment:
#    - Ecosystem
#    - Services
#    - Runtime
#    - Fix-All-Four
#    - Cleanup + Lint
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

G='\033[1;32m'; Y='\033[1;33m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[BOOT]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

cd "$ROOT"

run_if_present() {
  local label="$1"
  local script="$2"
  step "$label"
  [[ -x "$script" ]] && "$script" || warn "Skipping: $script"
}

run_if_present "1/6 — Ecosystem core"        "$ROOT/scripts/ds-ecosystem.sh"
run_if_present "2/6 — Ecosystem bundle"      "$ROOT/scripts/ds-bundle-ecosystem.sh"
run_if_present "3/6 — Services bundle"       "$ROOT/scripts/ds-bundle-services.sh"
run_if_present "4/6 — Runtime bundle"        "$ROOT/scripts/ds-bundle-runtime.sh"
run_if_present "5/6 — Fix-All-Four"          "$ROOT/scripts/ds-fix-all-four.sh"
run_if_present "6/6 — Cleanup legacy refs"   "$ROOT/scripts/ds-cleanup-legacy.sh"

step "Final lint pass"
"$ROOT/scripts/ds-lint-names.sh"

echo -e "${M}Bootstrap complete.${N}"
