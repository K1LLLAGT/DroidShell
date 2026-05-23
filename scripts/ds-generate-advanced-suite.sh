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
