#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
mkdir -p "$SCRIPTS"
G='\033[1;32m'; Y='\033[1;33m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[MASTER]${N} $*"; }
warn(){ echo -e "${Y}[WARN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "Writing GIT-SUMMARY.txt"
cat > "$ROOT/GIT-SUMMARY.txt" << 'EOF_GITSUM'
DROIDSHELL – GIT CHANGE SUMMARY
===============================
(See generator for details; this is a stage-0 bootstrap summary placeholder.)
EOF_GITSUM
log "GIT-SUMMARY.txt written."

step "Writing README.txt"
cat > "$ROOT/README.txt" << 'EOF_README'
DROIDSHELL – SYSTEM OVERVIEW
============================
(See generator for details; this is a stage-0 bootstrap README placeholder.)
EOF_README
log "README.txt written."

step "Invoking tier generators (if present)"
run_gen(){ local gen="$1"; if [[ -x "$SCRIPTS/$gen" ]]; then log "Running $gen"; bash "$SCRIPTS/$gen"; else warn "Missing: $gen"; fi; }
run_gen ds-generate-module-suite.sh
run_gen ds-generate-advanced-suite.sh
run_gen ds-generate-fix-suite.sh
run_gen ds-generate-next-tier-suite.sh
run_gen ds-generate-next-tier-2-suite.sh
run_gen ds-generate-next-tier-3-suite.sh
run_gen ds-generate-next-tier-4-suite.sh
run_gen ds-generate-next-tier-5-suite.sh
run_gen ds-generate-next-tier-7-suite.sh

step "Master suite generation complete."
log "DroidShell master regeneration finished."
