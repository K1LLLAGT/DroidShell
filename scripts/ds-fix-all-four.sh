#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$HOME/DroidShell"

G='\033[1;32m'; Y='\033[1;33m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[DS]${N} $*"; }
warn() { echo -e "${Y}[!]${N}  $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

cd "$BASE_DIR"

step "1/2 — Rebuild OTA metadata"
[[ -x scripts/ds-ota-metadata.sh ]] && scripts/ds-ota-metadata.sh || warn "OTA metadata script missing"

step "2/2 — Run ds-fix-all-three.sh"
[[ -x scripts/ds-fix-all-three.sh ]] && scripts/ds-fix-all-three.sh || { warn "ds-fix-all-three missing"; exit 1; }

echo -e "${M}Fix-All-Four complete${N}"
