#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Stage-0 Bootstrap
#
#  Purpose:
#    From an almost-empty ~/DroidShell, recreate:
#      - scripts/ directory
#      - all ds-generate-*.sh generators
#      - ds-generate-master-suite.sh
#    Then run the master generator to rebuild the full ds-* ecosystem.
#
#  Usage:
#    bash ds-stage0-bootstrap.sh
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"

mkdir -p "$SCRIPTS"

G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[STAGE0]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

# -----------------------------------------------------------------------------
# 1. ds-generate-module-suite.sh
# -----------------------------------------------------------------------------
step "Writing ds-generate-module-suite.sh"

cat > "$SCRIPTS/ds-generate-module-suite.sh" << 'GEN_MODULE_EOF'
#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Module Framework Suite Generator
#
#  Creates:
#    - ds-module-registry.sh
#    - ds-module-metadata.sh
#    - ds-module-tree.sh
#    - ds-module-docs.sh
#    - ds-module-search.sh
# =============================================================================

set -euo pipefail

BASE="$HOME/DroidShell/scripts"
mkdir -p "$BASE"

G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

# 1/5 ds-module-registry.sh
step "1/5 — Writing ds-module-registry.sh"
cat > "$BASE/ds-module-registry.sh" << 'EOF_REG'
#!/usr/bin/env bash
# ds-module-registry.sh
set -euo pipefail
ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
REG="$ROOT/registry"
META="$REG/meta"
mkdir -p "$META"
: > "$META/modules.list"
for f in "$SCRIPTS"/ds-*.sh; do
  [ -f "$f" ] || continue
  echo "$(basename "$f")" >> "$META/modules.list"
done
echo "[REGISTRY] Updated: $META/modules.list"
EOF_REG
chmod +x "$BASE/ds-module-registry.sh"
log "Created ds-module-registry.sh"

# 2/5 ds-module-metadata.sh
step "2/5 — Writing ds-module-metadata.sh"
cat > "$BASE/ds-module-metadata.sh" << 'EOF_META'
#!/usr/bin/env bash
# ds-module-metadata.sh
set -euo pipefail
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
META="$REG/meta"
mkdir -p "$META"
script="${1:-}"
[ -z "$script" ] && { echo "Usage: ds-module-metadata.sh <script>"; exit 1; }
out="$META/$script.meta"
grep -E '^#' "$ROOT/scripts/$script" > "$out" || true
echo "[META] Wrote: $out"
EOF_META
chmod +x "$BASE/ds-module-metadata.sh"
log "Created ds-module-metadata.sh"

# 3/5 ds-module-tree.sh
step "3/5 — Writing ds-module-tree.sh"
cat > "$BASE/ds-module-tree.sh" << 'EOF_TREE'
#!/usr/bin/env bash
# ds-module-tree.sh
set -euo pipefail
ROOT="$HOME/DroidShell"
OUT="$ROOT/droidshell-tree.txt"
cd "$ROOT"
find . -maxdepth 4 -print | sort > "$OUT"
echo "[TREE] Wrote: $OUT"
EOF_TREE
chmod +x "$BASE/ds-module-tree.sh"
log "Created ds-module-tree.sh"

# 4/5 ds-module-docs.sh
step "4/5 — Writing ds-module-docs.sh"
cat > "$BASE/ds-module-docs.sh" << 'EOF_DOCS'
#!/usr/bin/env bash
# ds-module-docs.sh
set -euo pipefail
ROOT="$HOME/DroidShell"
DOCS="$ROOT/registry/docs"
mkdir -p "$DOCS"
for f in "$ROOT"/scripts/ds-*.sh; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  out="$DOCS/$base.txt"
  grep -E '^#' "$f" > "$out" || true
done
echo "[DOCS] Docs written to: $DOCS"
EOF_DOCS
chmod +x "$BASE/ds-module-docs.sh"
log "Created ds-module-docs.sh"

# 5/5 ds-module-search.sh
step "5/5 — Writing ds-module-search.sh"
cat > "$BASE/ds-module-search.sh" << 'EOF_SEARCH'
#!/usr/bin/env bash
# ds-module-search.sh
set -euo pipefail
ROOT="$HOME/DroidShell"
term="${1:-}"
[ -z "$term" ] && { echo "Usage: ds-module-search.sh <term>"; exit 1; }
grep -Rni --color=always "$term" "$ROOT/scripts" || true
EOF_SEARCH
chmod +x "$BASE/ds-module-search.sh"
log "Created ds-module-search.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Module Framework Suite Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
GEN_MODULE_EOF

chmod +x "$SCRIPTS/ds-generate-module-suite.sh"
log "ds-generate-module-suite.sh written."

# -----------------------------------------------------------------------------
# 2. ds-generate-advanced-suite.sh
# -----------------------------------------------------------------------------
step "Writing ds-generate-advanced-suite.sh"

cat > "$SCRIPTS/ds-generate-advanced-suite.sh" << 'GEN_ADV_EOF'
#!/usr/bin/env bash
# Advanced Maintenance Suite Generator
set -euo pipefail
BASE="$HOME/DroidShell/scripts"
mkdir -p "$BASE"
G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/3 — Writing ds-cleanup-legacy.sh"
cat > "$BASE/ds-cleanup-legacy.sh" << 'EOF_CLEAN'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
echo "[CLEANUP] No-op placeholder for legacy cleanup."
EOF_CLEAN
chmod +x "$BASE/ds-cleanup-legacy.sh"
log "Created ds-cleanup-legacy.sh"

step "2/3 — Writing ds-lint-names.sh"
cat > "$BASE/ds-lint-names.sh" << 'EOF_LINT'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
cd "$ROOT/scripts"
ls droidshell-* 2>/dev/null && echo "[LINT] Legacy names found." || echo "[LINT] OK"
EOF_LINT
chmod +x "$BASE/ds-lint-names.sh"
log "Created ds-lint-names.sh"

step "3/3 — Writing ds-bootstrap-all.sh"
cat > "$BASE/ds-bootstrap-all.sh" << 'EOF_BOOT'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
echo "[BOOTSTRAP] Running module registry..."
"$ROOT/scripts/ds-module-registry.sh" || true
echo "[BOOTSTRAP] Running module tree..."
"$ROOT/scripts/ds-module-tree.sh" || true
echo "[BOOTSTRAP] Done."
EOF_BOOT
chmod +x "$BASE/ds-bootstrap-all.sh"
log "Created ds-bootstrap-all.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Advanced Maintenance Suite Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
GEN_ADV_EOF

chmod +x "$SCRIPTS/ds-generate-advanced-suite.sh"
log "ds-generate-advanced-suite.sh written."

# -----------------------------------------------------------------------------
# 3. ds-generate-fix-suite.sh
# -----------------------------------------------------------------------------
step "Writing ds-generate-fix-suite.sh"

cat > "$SCRIPTS/ds-generate-fix-suite.sh" << 'GEN_FIX_EOF'
#!/usr/bin/env bash
# Fix Suite Generator
set -euo pipefail
BASE="$HOME/DroidShell/scripts"
mkdir -p "$BASE"
G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "Writing ds-fix-all-three.sh"
cat > "$BASE/ds-fix-all-three.sh" << 'EOF_F3'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
"$ROOT/scripts/ds-module-registry.sh" || true
"$ROOT/scripts/ds-module-tree.sh" || true
"$ROOT/scripts/ds-module-docs.sh" || true
EOF_F3
chmod +x "$BASE/ds-fix-all-three.sh"
log "Created ds-fix-all-three.sh"

step "Writing ds-fix-all-four.sh"
cat > "$BASE/ds-fix-all-four.sh" << 'EOF_F4'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
"$ROOT/scripts/ds-module-registry.sh" || true
"$ROOT/scripts/ds-module-tree.sh" || true
"$ROOT/scripts/ds-module-docs.sh" || true
"$ROOT/scripts/ds-module-search.sh" "ds-" || true
EOF_F4
chmod +x "$BASE/ds-fix-all-four.sh"
log "Created ds-fix-all-four.sh"

step "Writing ds-fix-everything.sh"
cat > "$BASE/ds-fix-everything.sh" << 'EOF_FE'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
"$ROOT/scripts/ds-fix-all-four.sh" || true
EOF_FE
chmod +x "$BASE/ds-fix-everything.sh"
log "Created ds-fix-everything.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Fix Suite Generator — COMPLETE${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
GEN_FIX_EOF

chmod +x "$SCRIPTS/ds-generate-fix-suite.sh"
log "ds-generate-fix-suite.sh written."

# -----------------------------------------------------------------------------
# 4. ds-generate-next-tier-suite.sh (module extras)
# -----------------------------------------------------------------------------
step "Writing ds-generate-next-tier-suite.sh"

cat > "$SCRIPTS/ds-generate-next-tier-suite.sh" << 'GEN_NEXT_EOF'
#!/usr/bin/env bash
# Next Tier Module Suite Generator
set -euo pipefail
BASE="$HOME/DroidShell/scripts"
mkdir -p "$BASE"
G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/5 — Writing ds-module-categories.sh"
cat > "$BASE/ds-module-categories.sh" << 'EOF_CAT'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
for f in "$ROOT"/scripts/ds-*.sh; do
  echo "$(basename "$f")"
done
EOF_CAT
chmod +x "$BASE/ds-module-categories.sh"
log "Created ds-module-categories.sh"

step "2/5 — Writing ds-module-deps.sh"
cat > "$BASE/ds-module-deps.sh" << 'EOF_DEPS'
#!/usr/bin/env bash
set -euo pipefail
echo "[DEPS] Placeholder dependency viewer."
EOF_DEPS
chmod +x "$BASE/ds-module-deps.sh"
log "Created ds-module-deps.sh"

step "3/5 — Writing ds-module-versioning.sh"
cat > "$BASE/ds-module-versioning.sh" << 'EOF_VER'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
REG="$ROOT/registry/versions"
mkdir -p "$REG"
echo "1.0.0" > "$REG/version.txt"
echo "[VERSION] 1.0.0"
EOF_VER
chmod +x "$BASE/ds-module-versioning.sh"
log "Created ds-module-versioning.sh"

step "4/5 — Writing ds-module-installer.sh"
cat > "$BASE/ds-module-installer.sh" << 'EOF_INST'
#!/usr/bin/env bash
set -euo pipefail
echo "[INSTALLER] Placeholder installer."
EOF_INST
chmod +x "$BASE/ds-module-installer.sh"
log "Created ds-module-installer.sh"

step "5/5 — Writing ds-module-sandbox-suite.sh"
cat > "$BASE/ds-module-sandbox-suite.sh" << 'EOF_SBOX'
#!/usr/bin/env bash
set -euo pipefail
echo "[SANDBOX] Placeholder sandbox suite."
EOF_SBOX
chmod +x "$BASE/ds-module-sandbox-suite.sh"
log "Created ds-module-sandbox-suite.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier Module Suite Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
GEN_NEXT_EOF

chmod +x "$SCRIPTS/ds-generate-next-tier-suite.sh"
log "ds-generate-next-tier-suite.sh written."

# -----------------------------------------------------------------------------
# 5. ds-generate-next-tier-2-suite.sh (Distribution + Dev UX)
# -----------------------------------------------------------------------------
step "Writing ds-generate-next-tier-2-suite.sh"

cat > "$SCRIPTS/ds-generate-next-tier-2-suite.sh" << 'GEN_T2_EOF'
#!/usr/bin/env bash
# Distribution + Developer UX
set -euo pipefail
BASE="$HOME/DroidShell/scripts"
ROOT="$HOME/DroidShell"
mkdir -p "$BASE"
G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/7 — Writing ds-dist-export.sh"
cat > "$BASE/ds-dist-export.sh" << 'EOF_EXPORT'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
OUT="$ROOT/out/droidshell-export-$(date +%Y%m%d-%H%M%S).tar.gz"
mkdir -p "$ROOT/out"
tar -czf "$OUT" -C "$ROOT" .
echo "[EXPORT] $OUT"
EOF_EXPORT
chmod +x "$BASE/ds-dist-export.sh"
log "Created ds-dist-export.sh"

step "2/7 — Writing ds-dist-import.sh"
cat > "$BASE/ds-dist-import.sh" << 'EOF_IMPORT'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
ARCHIVE="${1:-}"
[ -z "$ARCHIVE" ] && { echo "Usage: ds-dist-import.sh <archive>"; exit 1; }
tar -xzf "$ARCHIVE" -C "$ROOT"
echo "[IMPORT] $ARCHIVE"
EOF_IMPORT
chmod +x "$BASE/ds-dist-import.sh"
log "Created ds-dist-import.sh"

step "3/7 — Writing ds-dist-profile.sh"
cat > "$BASE/ds-dist-profile.sh" << 'EOF_PROFILE'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
STATE="$ROOT/registry/state"
PROFILES="$ROOT/registry/profiles"
mkdir -p "$STATE" "$PROFILES"
cmd="${1:-}"; name="${2:-}"
case "$cmd" in
  save) [ -z "$name" ] && { echo "Usage: save <name>"; exit 1; }
        cp -r "$STATE" "$PROFILES/$name";;
  load) [ -z "$name" ] && { echo "Usage: load <name>"; exit 1; }
        cp -r "$PROFILES/$name" "$STATE";;
  list) ls "$PROFILES";;
  *) echo "Usage: $0 {save|load|list}";;
esac
EOF_PROFILE
chmod +x "$BASE/ds-dist-profile.sh"
log "Created ds-dist-profile.sh"

step "4/7 — Writing ds-dist-preset.sh"
cat > "$BASE/ds-dist-preset.sh" << 'EOF_PRESET'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
STATE="$ROOT/registry/state"
mkdir -p "$STATE"
preset="${1:-}"
case "$preset" in
  minimal) find "$STATE" -type f -delete;;
  full)    for f in "$ROOT"/scripts/ds-*.sh; do
             echo "enabled" > "$STATE/$(basename "$f").state"
           done;;
  *) echo "Usage: $0 {minimal|full}";;
esac
EOF_PRESET
chmod +x "$BASE/ds-dist-preset.sh"
log "Created ds-dist-preset.sh"

step "5/7 — Writing ds-dev-tui.sh"
cat > "$BASE/ds-dev-tui.sh" << 'EOF_TUI'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell/scripts"
while true; do
  clear
  echo "=== DroidShell TUI ==="
  select f in $(ls "$ROOT"/ds-*.sh) "Exit"; do
    case "$f" in
      Exit) exit 0;;
      *) bash "$f"; break;;
    esac
  done
done
EOF_TUI
chmod +x "$BASE/ds-dev-tui.sh"
log "Created ds-dev-tui.sh"

step "6/7 — Writing ds-dev-launcher.sh"
cat > "$BASE/ds-dev-launcher.sh" << 'EOF_LAUNCH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell/scripts"
pattern="${1:-}"
[ -z "$pattern" ] && { echo "Usage: ds-dev-launcher.sh <pattern>"; exit 1; }
match=$(ls "$ROOT"/ds-*.sh | grep -i "$pattern" | head -1)
[ -z "$match" ] && { echo "[LAUNCH] No match"; exit 1; }
bash "$match"
EOF_LAUNCH
chmod +x "$BASE/ds-dev-launcher.sh"
log "Created ds-dev-launcher.sh"

step "7/7 — Writing ds-dev-help.sh"
cat > "$BASE/ds-dev-help.sh" << 'EOF_HELP'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell/scripts"
script="${1:-}"
[ -z "$script" ] && { echo "Usage: ds-dev-help.sh <script>"; exit 1; }
grep -E '^#' "$ROOT/$script" || true
EOF_HELP
chmod +x "$BASE/ds-dev-help.sh"
log "Created ds-dev-help.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 2 (Distribution + Developer UX) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
GEN_T2_EOF

chmod +x "$SCRIPTS/ds-generate-next-tier-2-suite.sh"
log "ds-generate-next-tier-2-suite.sh written."

# -----------------------------------------------------------------------------
# 6. ds-generate-next-tier-3-suite.sh (Observability + Policy)
# -----------------------------------------------------------------------------
step "Writing ds-generate-next-tier-3-suite.sh"

cat > "$SCRIPTS/ds-generate-next-tier-3-suite.sh" << 'GEN_T3_EOF'
#!/usr/bin/env bash
# Observability + Policy/Safety
set -euo pipefail
BASE="$HOME/DroidShell/scripts"
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
mkdir -p "$BASE" "$REG"
G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/8 — Writing ds-obs-metrics.sh"
cat > "$BASE/ds-obs-metrics.sh" << 'EOF_METRICS'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
METRICS="$ROOT/registry/metrics.log"
cmd="${1:-}"; shift || true
case "$cmd" in
  log) script="${1:-}"; status="${2:-}"
       [ -z "$script" ] && exit 1
       echo "$(date +%Y-%m-%dT%H:%M:%S) $script $status" >> "$METRICS";;
  summary)
       [ -f "$METRICS" ] && awk '{print $2, $3}' "$METRICS" | sort | uniq -c | sort -nr || echo "No metrics";;
  *) echo "Usage: $0 {log|summary}";;
esac
EOF_METRICS
chmod +x "$BASE/ds-obs-metrics.sh"
log "Created ds-obs-metrics.sh"

step "2/8 — Writing ds-obs-timing.sh"
cat > "$BASE/ds-obs-timing.sh" << 'EOF_TIMING'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/timing.log"
script="${1:-}"; shift || true
[ -z "$script" ] && { echo "Usage: ds-obs-timing.sh <script> [args...]"; exit 1; }
start=$(date +%s)
bash "$ROOT/scripts/$script" "$@"
status=$?
end=$(date +%s)
dur=$((end-start))
echo "$(date +%Y-%m-%dT%H:%M:%S) $script status=$status duration=${dur}s" >> "$LOG"
echo "[TIMING] $script ${dur}s"
exit $status
EOF_TIMING
chmod +x "$BASE/ds-obs-timing.sh"
log "Created ds-obs-timing.sh"

step "3/8 — Writing ds-obs-history.sh"
cat > "$BASE/ds-obs-history.sh" << 'EOF_HISTORY'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
METRICS="$ROOT/registry/metrics.log"
TIMING="$ROOT/registry/timing.log"
cmd="${1:-}"
case "$cmd" in
  metrics) [ -f "$METRICS" ] && cat "$METRICS" || echo "No metrics";;
  timing)  [ -f "$TIMING" ] && cat "$TIMING" || echo "No timing";;
  *) echo "Usage: $0 {metrics|timing}";;
esac
EOF_HISTORY
chmod +x "$BASE/ds-obs-history.sh"
log "Created ds-obs-history.sh"

step "4/8 — Writing ds-obs-profiler.sh"
cat > "$BASE/ds-obs-profiler.sh" << 'EOF_PROF'
#!/usr/bin/env bash
set -euo pipefail
script="${1:-}"; count="${2:-}"; shift 2 || true
[ -z "$script" ] || [ -z "$count" ] && { echo "Usage: ds-obs-profiler.sh <script> <count> [args...]"; exit 1; }
total=0
for i in $(seq 1 "$count"); do
  start=$(date +%s)
  bash "$HOME/DroidShell/scripts/$script" "$@"
  status=$?
  end=$(date +%s)
  dur=$((end-start))
  echo "[PROF] run $i: ${dur}s (status=$status)"
  total=$((total+dur))
done
avg=$((total/count))
echo "[PROF] average: ${avg}s"
EOF_PROF
chmod +x "$BASE/ds-obs-profiler.sh"
log "Created ds-obs-profiler.sh"

step "5/8 — Writing ds-policy-guard.sh"
cat > "$BASE/ds-policy-guard.sh" << 'EOF_GUARD'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
STATE_DIR="$ROOT/registry/state"
mkdir -p "$STATE_DIR"
cmd="${1:-}"; script="${2:-}"
[ "$cmd" != "check" ] && { echo "Usage: ds-policy-guard.sh check <script>"; exit 1; }
sf="$STATE_DIR/$(basename "$script").state"
[ -f "$sf" ] && [ "$(cat "$sf")" = "disabled" ] && { echo "[GUARD] disabled"; exit 1; }
echo "[GUARD] ok"
EOF_GUARD
chmod +x "$BASE/ds-policy-guard.sh"
log "Created ds-policy-guard.sh"

step "6/8 — Writing ds-policy-invariants.sh"
cat > "$BASE/ds-policy-invariants.sh" << 'EOF_INV'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
[ -d "$ROOT/scripts" ] || { echo "[INV] missing scripts/"; exit 1; }
echo "[INV] OK"
EOF_INV
chmod +x "$BASE/ds-policy-invariants.sh"
log "Created ds-policy-invariants.sh"

step "7/8 — Writing ds-policy-preflight.sh"
cat > "$BASE/ds-policy-preflight.sh" << 'EOF_PREF'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
op="${1:-}"
[ -z "$op" ] && { echo "Usage: ds-policy-preflight.sh <operation>"; exit 1; }
"$ROOT/scripts/ds-policy-invariants.sh"
echo "[PREFLIGHT] OK for $op"
EOF_PREF
chmod +x "$BASE/ds-policy-preflight.sh"
log "Created ds-policy-preflight.sh"

step "8/8 — Writing ds-policy-rollback.sh"
cat > "$BASE/ds-policy-rollback.sh" << 'EOF_ROLL'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
cmd="${1:-}"
case "$cmd" in
  last) cd "$ROOT"
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          git reset --hard HEAD~1
        else
          echo "Not a git repo"; exit 1
        fi;;
  *) echo "Usage: $0 last";;
esac
EOF_ROLL
chmod +x "$BASE/ds-policy-rollback.sh"
log "Created ds-policy-rollback.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 3 (Observability + Policy/Safety) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
GEN_T3_EOF

chmod +x "$SCRIPTS/ds-generate-next-tier-3-suite.sh"
log "ds-generate-next-tier-3-suite.sh written."

# -----------------------------------------------------------------------------
# 7. ds-generate-next-tier-4-suite.sh (Auto-update + Integrity)
# -----------------------------------------------------------------------------
step "Writing ds-generate-next-tier-4-suite.sh"

cat > "$SCRIPTS/ds-generate-next-tier-4-suite.sh" << 'GEN_T4_EOF'
#!/usr/bin/env bash
# Auto-update + Integrity
set -euo pipefail
BASE="$HOME/DroidShell/scripts"
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
mkdir -p "$BASE" "$REG"
G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/6 — Writing ds-auto-update.sh"
cat > "$BASE/ds-auto-update.sh" << 'EOF_AUTO'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
cd "$ROOT"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git pull --rebase
fi
[ -x "$ROOT/scripts/ds-bootstrap-all.sh" ] && "$ROOT/scripts/ds-bootstrap-all.sh"
EOF_AUTO
chmod +x "$BASE/ds-auto-update.sh"
log "Created ds-auto-update.sh"

step "2/6 — Writing ds-auto-hardening.sh"
cat > "$BASE/ds-auto-hardening.sh" << 'EOF_HARD'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
find "$ROOT/scripts" -type f -name "*.sh" -exec chmod 750 {} \;
chmod -R 700 "$ROOT/registry"
EOF_HARD
chmod +x "$BASE/ds-auto-hardening.sh"
log "Created ds-auto-hardening.sh"

step "3/6 — Writing ds-auto-sync.sh"
cat > "$BASE/ds-auto-sync.sh" << 'EOF_SYNC'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
REMOTE="${1:-origin}"
cd "$ROOT"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add -A
  git commit -m "Auto-sync $(date +%Y-%m-%dT%H:%M:%S)" || true
  git push "$REMOTE" HEAD || true
fi
EOF_SYNC
chmod +x "$BASE/ds-auto-sync.sh"
log "Created ds-auto-sync.sh"

step "4/6 — Writing ds-integrity-snapshot.sh"
cat > "$BASE/ds-integrity-snapshot.sh" << 'EOF_SNAP'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
OUT="$ROOT/registry/integrity.snapshot"
cd "$ROOT"
find . -type f ! -path "./.git/*" ! -path "./out/*" -print0 | sort -z | xargs -0 sha256sum > "$OUT"
echo "[INTEGRITY] Snapshot: $OUT"
EOF_SNAP
chmod +x "$BASE/ds-integrity-snapshot.sh"
log "Created ds-integrity-snapshot.sh"

step "5/6 — Writing ds-integrity-compare.sh"
cat > "$BASE/ds-integrity-compare.sh" << 'EOF_COMP'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
SNAP="$ROOT/registry/integrity.snapshot"
[ -f "$SNAP" ] || { echo "No snapshot"; exit 1; }
cd "$ROOT"
TMP=$(mktemp)
find . -type f ! -path "./.git/*" ! -path "./out/*" -print0 | sort -z | xargs -0 sha256sum > "$TMP"
diff -u "$SNAP" "$TMP" || { echo "Differences detected"; rm -f "$TMP"; exit 1; }
rm -f "$TMP"
echo "No differences."
EOF_COMP
chmod +x "$BASE/ds-integrity-compare.sh"
log "Created ds-integrity-compare.sh"

step "6/6 — Writing ds-integrity-daemon.sh"
cat > "$BASE/ds-integrity-daemon.sh" << 'EOF_DAEMON'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
INTERVAL="${1:-300}"
[ -f "$ROOT/registry/integrity.snapshot" ] || "$ROOT/scripts/ds-integrity-snapshot.sh"
while true; do
  "$ROOT/scripts/ds-integrity-compare.sh" || echo "[INTEGRITY] mismatch"
  sleep "$INTERVAL"
done
EOF_DAEMON
chmod +x "$BASE/ds-integrity-daemon.sh"
log "Created ds-integrity-daemon.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 4 (Auto-update + Integrity) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
GEN_T4_EOF

chmod +x "$SCRIPTS/ds-generate-next-tier-4-suite.sh"
log "ds-generate-next-tier-4-suite.sh written."

# -----------------------------------------------------------------------------
# 8. ds-generate-next-tier-5-suite.sh (Telemetry + Lab)
# -----------------------------------------------------------------------------
step "Writing ds-generate-next-tier-5-suite.sh"

cat > "$SCRIPTS/ds-generate-next-tier-5-suite.sh" << 'GEN_T5_EOF'
#!/usr/bin/env bash
# Analytics + Lab Harness
set -euo pipefail
BASE="$HOME/DroidShell/scripts"
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
mkdir -p "$BASE" "$REG"
G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/6 — Writing ds-telemetry-log.sh"
cat > "$BASE/ds-telemetry-log.sh" << 'EOF_TLOG'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/telemetry.log"
event="${1:-}"; shift || true
[ -z "$event" ] && { echo "Usage: ds-telemetry-log.sh <event> [key=value ...]"; exit 1; }
echo "$(date +%Y-%m-%dT%H:%M:%S) event=$event $*" >> "$LOG"
EOF_TLOG
chmod +x "$BASE/ds-telemetry-log.sh"
log "Created ds-telemetry-log.sh"

step "2/6 — Writing ds-telemetry-report.sh"
cat > "$BASE/ds-telemetry-report.sh" << 'EOF_TREP'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/telemetry.log"
cmd="${1:-}"; shift || true
case "$cmd" in
  summary)
    [ -f "$LOG" ] || { echo "No telemetry"; exit 0; }
    awk '{for(i=1;i<=NF;i++) if($i ~ /^event=/){sub("event=","",$i); print $i}}' "$LOG" | sort | uniq -c | sort -nr;;
  recent)
    n="${1:-20}"
    [ -f "$LOG" ] && tail -n "$n" "$LOG" || echo "No telemetry";;
  *) echo "Usage: $0 {summary|recent [N]}";;
esac
EOF_TREP
chmod +x "$BASE/ds-telemetry-report.sh"
log "Created ds-telemetry-report.sh"

step "3/6 — Writing ds-crash-log.sh"
cat > "$BASE/ds-crash-log.sh" << 'EOF_CRASH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/crash.log"
script="${1:-}"; shift || true
[ -z "$script" ] && { echo "Usage: ds-crash-log.sh <script> [args...]"; exit 1; }
ts="$(date +%Y-%m-%dT%H:%M:%S)"
bash "$ROOT/scripts/$script" "$@"
status=$?
[ $status -ne 0 ] && echo "$ts script=$script status=$status args=\"$*\"" >> "$LOG"
exit $status
EOF_CRASH
chmod +x "$BASE/ds-crash-log.sh"
log "Created ds-crash-log.sh"

step "4/6 — Writing ds-lab-snapshot-env.sh"
cat > "$BASE/ds-lab-snapshot-env.sh" << 'EOF_LSNAP'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
name="${1:-}"
[ -z "$name" ] && { echo "Usage: ds-lab-snapshot-env.sh <name>"; exit 1; }
OUT="$REG/lab-env-${name}.snapshot"
{
  echo "# Lab snapshot: $name"
  echo "# Date: $(date)"
  echo "## env"
  env | sort
} > "$OUT"
echo "[LAB] $OUT"
EOF_LSNAP
chmod +x "$BASE/ds-lab-snapshot-env.sh"
log "Created ds-lab-snapshot-env.sh"

step "5/6 — Writing ds-lab-diff-env.sh"
cat > "$BASE/ds-lab-diff-env.sh" << 'EOF_LDIFF'
#!/usr/bin/env bash
set -euo pipefail
a="${1:-}"; b="${2:-}"
[ -z "$a" ] || [ -z "$b" ] && { echo "Usage: ds-lab-diff-env.sh <snapshot-a> <snapshot-b>"; exit 1; }
diff -u "$a" "$b" || { echo "[LAB] Differences"; exit 1; }
echo "[LAB] Identical"
EOF_LDIFF
chmod +x "$BASE/ds-lab-diff-env.sh"
log "Created ds-lab-diff-env.sh"

step "6/6 — Writing ds-lab-harness.sh"
cat > "$BASE/ds-lab-harness.sh" << 'EOF_LH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
label="${1:-}"; shift || true
script="${1:-}"; shift || true
[ -z "$label" ] || [ -z "$script" ] && { echo "Usage: ds-lab-harness.sh <label> <script> [args...]"; exit 1; }
"$ROOT/scripts/ds-telemetry-log.sh" "lab-start" label="$label" script="$script"
"$ROOT/scripts/ds-obs-timing.sh" "$script" "$@" || {
  "$ROOT/scripts/ds-crash-log.sh" "$script" "$@"
  "$ROOT/scripts/ds-telemetry-log.sh" "lab-fail" label="$label" script="$script"
  exit 1
}
"$ROOT/scripts/ds-telemetry-log.sh" "lab-success" label="$label" script="$script"
EOF_LH
chmod +x "$BASE/ds-lab-harness.sh"
log "Created ds-lab-harness.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 5 (Analytics + Lab Harness) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
GEN_T5_EOF

chmod +x "$SCRIPTS/ds-generate-next-tier-5-suite.sh"
log "ds-generate-next-tier-5-suite.sh written."

# -----------------------------------------------------------------------------
# 9. ds-generate-next-tier-7-suite.sh (Ops & Control)
# -----------------------------------------------------------------------------
step "Writing ds-generate-next-tier-7-suite.sh"

cat > "$SCRIPTS/ds-generate-next-tier-7-suite.sh" << 'GEN_T7_EOF'
#!/usr/bin/env bash
# Ops & Control Layer
set -euo pipefail
BASE="$HOME/DroidShell/scripts"
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
QUEUE="$REG/queue"
LOCKS="$REG/locks"
EVENTS="$REG/events"
mkdir -p "$BASE" "$REG" "$QUEUE" "$LOCKS" "$EVENTS"
G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/7 — Writing ds-ops-queue.sh"
cat > "$BASE/ds-ops-queue.sh" << 'EOF_QUEUE'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
QUEUE="$ROOT/registry/queue"
cmd="${1:-}"; shift || true
case "$cmd" in
  add) job_id="$(date +%s)-$RANDOM"; echo "$@" > "$QUEUE/$job_id.job"; echo "$job_id";;
  list) ls "$QUEUE";;
  *) echo "Usage: $0 {add|list}";;
esac
EOF_QUEUE
chmod +x "$BASE/ds-ops-queue.sh"
log "Created ds-ops-queue.sh"

step "2/7 — Writing ds-ops-worker.sh"
cat > "$BASE/ds-ops-worker.sh" << 'EOF_WORKER'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
QUEUE="$ROOT/registry/queue"
while true; do
  job=$(ls "$QUEUE"/*.job 2>/dev/null | head -1 || true)
  [ -z "$job" ] && { sleep 1; continue; }
  read -r script args < "$job"
  bash "$ROOT/scripts/$script" $args || echo "[WORKER] Job failed"
  rm -f "$job"
done
EOF_WORKER
chmod +x "$BASE/ds-ops-worker.sh"
log "Created ds-ops-worker.sh"

step "3/7 — Writing ds-ops-lock.sh"
cat > "$BASE/ds-ops-lock.sh" << 'EOF_LOCK'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOCKS="$ROOT/registry/locks"
name="${1:-}"
[ -z "$name" ] && { echo "Usage: ds-ops-lock.sh <name>"; exit 1; }
lock="$LOCKS/$name.lock"
[ -f "$lock" ] && { echo "Locked"; exit 1; }
echo $$ > "$lock"
EOF_LOCK
chmod +x "$BASE/ds-ops-lock.sh"
log "Created ds-ops-lock.sh"

step "4/7 — Writing ds-ops-unlock.sh"
cat > "$BASE/ds-ops-unlock.sh" << 'EOF_UNLOCK'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOCKS="$ROOT/registry/locks"
name="${1:-}"
[ -z "$name" ] && { echo "Usage: ds-ops-unlock.sh <name>"; exit 1; }
rm -f "$LOCKS/$name.lock"
EOF_UNLOCK
chmod +x "$BASE/ds-ops-unlock.sh"
log "Created ds-ops-unlock.sh"

step "5/7 — Writing ds-ops-rotate-snapshots.sh"
cat > "$BASE/ds-ops-rotate-snapshots.sh" << 'EOF_RS'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
SNAPS="$ROOT/registry"
count="${1:-5}"
ls -t "$SNAPS"/integrity.snapshot* 2>/dev/null | tail -n +$((count+1)) | xargs -r rm -f
EOF_RS
chmod +x "$BASE/ds-ops-rotate-snapshots.sh"
log "Created ds-ops-rotate-snapshots.sh"

step "6/7 — Writing ds-ops-rotate-backups.sh"
cat > "$BASE/ds-ops-rotate-backups.sh" << 'EOF_RB'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
OUT="$ROOT/out"
count="${1:-5}"
ls -t "$OUT"/droidshell-export-* 2>/dev/null | tail -n +$((count+1)) | xargs -r rm -f
EOF_RB
chmod +x "$BASE/ds-ops-rotate-backups.sh"
log "Created ds-ops-rotate-backups.sh"

step "7/7 — Writing ds-ops-event-bus.sh"
cat > "$BASE/ds-ops-event-bus.sh" << 'EOF_EVENT'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
EVENTS="$ROOT/registry/events"
cmd="${1:-}"; shift || true
case "$cmd" in
  emit) ts=$(date +%Y-%m-%dT%H:%M:%S); echo "$ts $*" >> "$EVENTS/bus.log";;
  tail) tail -f "$EVENTS/bus.log";;
  *) echo "Usage: $0 {emit|tail}";;
esac
EOF_EVENT
chmod +x "$BASE/ds-ops-event-bus.sh"
log "Created ds-ops-event-bus.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 7 (Ops & Control Layer) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
GEN_T7_EOF

chmod +x "$SCRIPTS/ds-generate-next-tier-7-suite.sh"
log "ds-generate-next-tier-7-suite.sh written."

# -----------------------------------------------------------------------------
# 10. ds-generate-master-suite.sh
# -----------------------------------------------------------------------------
step "Writing ds-generate-master-suite.sh"

cat > "$SCRIPTS/ds-generate-master-suite.sh" << 'MASTER_EOF'
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
MASTER_EOF

chmod +x "$SCRIPTS/ds-generate-master-suite.sh"
log "ds-generate-master-suite.sh written."

# -----------------------------------------------------------------------------
# 11. Run master generator
# -----------------------------------------------------------------------------
step "Running master generator"
bash "$SCRIPTS/ds-generate-master-suite.sh"

step "Stage-0 bootstrap complete."
log "DroidShell fully regenerated from stage-0."
