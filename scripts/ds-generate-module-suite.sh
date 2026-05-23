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
