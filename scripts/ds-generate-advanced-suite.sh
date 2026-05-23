#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Advanced Maintenance Suite Generator
#
#  Creates:
#    - ds-cleanup-legacy.sh
#    - ds-lint-names.sh
#    - ds-bootstrap-all.sh
#
#  Output directory:
#    ~/DroidShell/scripts/
# =============================================================================

set -euo pipefail

BASE="$HOME/DroidShell/scripts"
mkdir -p "$BASE"

G='\033[1;32m'; M='\033[1;35m'; Y='\033[1;33m'; N='\033[0m'
log()  { echo -e "${G}[GEN]${N} $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

# =============================================================================
step "1/3 — Writing ds-cleanup-legacy.sh"
# =============================================================================
cat > "$BASE/ds-cleanup-legacy.sh" << 'EOF_CLEAN'
#!/usr/bin/env bash
# =============================================================================
#  ds-cleanup-legacy.sh
#  Removes leftover "droidshell-" references repo‑wide.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'
log()  { echo -e "${G}[CLEAN]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N}  $*"; }

cd "$ROOT"

log "Scanning for legacy references…"

grep -RIl "droidshell-" "$ROOT" | while read -r FILE; do
  log "Fixing: $FILE"
  sed -i 's/droidshell-/ds-/g' "$FILE"
done

log "Cleanup complete."
EOF_CLEAN

chmod +x "$BASE/ds-cleanup-legacy.sh"
log "Created ds-cleanup-legacy.sh"

# =============================================================================
step "2/3 — Writing ds-lint-names.sh"
# =============================================================================
cat > "$BASE/ds-lint-names.sh" << 'EOF_LINT'
#!/usr/bin/env bash
# =============================================================================
#  ds-lint-names.sh
#  Verifies naming consistency across all scripts.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell/scripts"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[LINT]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N}  $*"; }
err()  { echo -e "${R}[ERR]${N}   $*"; }

cd "$ROOT"

log "Checking for legacy script names…"

BAD=$(find "$ROOT" -maxdepth 1 -type f -name "droidshell-*.sh")

if [[ -z "$BAD" ]]; then
  log "No legacy script names found."
else
  warn "Legacy scripts detected:"
  echo "$BAD"
fi

log "Checking for legacy references inside scripts…"

grep -RIn "droidshell-" "$ROOT" || log "No legacy references found."

log "Lint complete."
EOF_LINT

chmod +x "$BASE/ds-lint-names.sh"
log "Created ds-lint-names.sh"

# =============================================================================
step "3/3 — Writing ds-bootstrap-all.sh"
# =============================================================================
cat > "$BASE/ds-bootstrap-all.sh" << 'EOF_BOOT'
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
EOF_BOOT

chmod +x "$BASE/ds-bootstrap-all.sh"
log "Created ds-bootstrap-all.sh"

# =============================================================================
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Advanced Maintenance Suite Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
