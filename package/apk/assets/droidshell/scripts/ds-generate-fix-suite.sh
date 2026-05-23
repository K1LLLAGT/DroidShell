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
