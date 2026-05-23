#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Fix-All-Four
#  ds-fix-all-four.sh
#
#  Tasks:
#    1. Rebuild OTA metadata
#    2. Run ds-fix-all-three.sh
# =============================================================================

set -euo pipefail

BASE_DIR="$HOME/DroidShell"
cd "$BASE_DIR"

G='\033[1;32m'; Y='\033[1;33m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[DS]${N} $*"; }
warn() { echo -e "${Y}[!]${N}  $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/2 — Rebuild OTA metadata"

if [[ -x scripts/ds-ota-metadata.sh ]]; then
  log "Running ds-ota-metadata.sh"
  scripts/ds-ota-metadata.sh
else
  warn "scripts/ds-ota-metadata.sh missing — skipping"
fi

step "2/2 — Run ds-fix-all-three.sh"

if [[ -x scripts/ds-fix-all-three.sh ]]; then
  scripts/ds-fix-all-three.sh
else
  warn "scripts/ds-fix-all-three.sh missing"
  exit 1
fi

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} ds-fix-all-four.sh — COMPLETE${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
