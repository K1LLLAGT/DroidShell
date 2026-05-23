#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Module Framework Suite Generator
#
#  Creates:
#    - ds-module-registry.sh   (index all modules)
#    - ds-module-metadata.sh   (attach/read metadata)
#    - ds-module-tree.sh       (hierarchical module tree)
#    - ds-module-docs.sh       (auto-generate docs)
#    - ds-module-search.sh     (search modules)
#
#  Output directory:
#    ~/DroidShell/scripts/
# =============================================================================

set -euo pipefail

BASE="$HOME/DroidShell/scripts"
ROOT="$HOME/DroidShell"
mkdir -p "$BASE"

G='\033[1;32m'; M='\033[1;35m'; Y='\033[1;33m'; N='\033[0m'
log()  { echo -e "${G}[GEN]${N} $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

# =============================================================================
step "1/5 — Writing ds-module-registry.sh"
# =============================================================================
cat > "$BASE/ds-module-registry.sh" << 'EOF_REG'
#!/usr/bin/env bash
# =============================================================================
#  ds-module-registry.sh
#  Builds a registry of all ds-* scripts with basic metadata.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
REGISTRY="$ROOT/registry/modules.txt"

G='\033[1;32m'; N='\033[0m'
log() { echo -e "${G}[REG]${N} $*"; }

mkdir -p "$(dirname "$REGISTRY")"

log "Building module registry at: $REGISTRY"

{
  echo "# DroidShell Module Registry"
  echo "# Generated: $(date)"
  echo "# Format: name|path|size|mtime"
  echo ""
  find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | while read -r f; do
    name="$(basename "$f")"
    size="$(stat -c '%s' "$f" 2>/dev/null || stat -f '%z' "$f")"
    mtime="$(stat -c '%y' "$f" 2>/dev/null || stat -f '%Sm' "$f")"
    echo "${name}|${f}|${size}|${mtime}"
  done
} > "$REGISTRY"

log "Registry written."
EOF_REG

chmod +x "$BASE/ds-module-registry.sh"
log "Created ds-module-registry.sh"

# =============================================================================
step "2/5 — Writing ds-module-metadata.sh"
# =============================================================================
cat > "$BASE/ds-module-metadata.sh" << 'EOF_META'
#!/usr/bin/env bash
# =============================================================================
#  ds-module-metadata.sh
#  Simple metadata system for modules (category, description, tags).
#
#  Usage:
#    ds-module-metadata.sh set <script> <key> <value>
#    ds-module-metadata.sh get <script> <key>
#    ds-module-metadata.sh show <script>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
META_DIR="$ROOT/registry/meta"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[META]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
err()  { echo -e "${R}[ERR]${N} $*"; exit 1; }

mkdir -p "$META_DIR"

cmd="${1:-}"; shift || true

meta_file_for() {
  local script="$1"
  local base
  base="$(basename "$script")"
  echo "$META_DIR/${base}.meta"
}

case "$cmd" in
  set)
    script="${1:-}"; key="${2:-}"; value="${3:-}"
    [[ -z "$script" || -z "$key" || -z "$value" ]] && err "Usage: set <script> <key> <value>"
    mf="$(meta_file_for "$script")"
    touch "$mf"
    # remove existing key
    grep -v "^${key}=" "$mf" 2>/dev/null > "${mf}.tmp" || true
    echo "${key}=${value}" >> "${mf}.tmp"
    mv "${mf}.tmp" "$mf"
    log "Set ${key} for $(basename "$script")"
    ;;
  get)
    script="${1:-}"; key="${2:-}"
    [[ -z "$script" || -z "$key" ]] && err "Usage: get <script> <key>"
    mf="$(meta_file_for "$script")"
    [[ -f "$mf" ]] || err "No metadata for $script"
    grep "^${key}=" "$mf" | head -1 | cut -d= -f2-
    ;;
  show)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: show <script>"
    mf="$(meta_file_for "$script")"
    [[ -f "$mf" ]] || { warn "No metadata for $script"; exit 0; }
    echo "# Metadata for $(basename "$script")"
    cat "$mf"
    ;;
  *)
    err "Usage: $0 {set|get|show} ..."
    ;;
esac
EOF_META

chmod +x "$BASE/ds-module-metadata.sh"
log "Created ds-module-metadata.sh"

# =============================================================================
step "3/5 — Writing ds-module-tree.sh"
# =============================================================================
cat > "$BASE/ds-module-tree.sh" << 'EOF_TREE'
#!/usr/bin/env bash
# =============================================================================
#  ds-module-tree.sh
#  Prints a hierarchical tree of modules and key bundles.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"

G='\033[1;32m'; N='\033[0m'
log() { echo -e "${G}[TREE]${N} $*"; }

cd "$ROOT"

log "DroidShell Module Tree"
echo ""

echo "scripts/"
find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | sed 's|.*/|  ├── |'

echo ""
echo "bundles:"
for b in ds-bundle-ecosystem.sh ds-bundle-services.sh ds-bundle-runtime.sh; do
  if [[ -f "$SCRIPTS/$b" ]]; then
    echo "  - $b"
  fi
done

echo ""
echo "orchestrators:"
for o in ds-bootstrap-all.sh ds-fix-everything.sh ds-release-master.sh; do
  if [[ -f "$SCRIPTS/$o" ]]; then
    echo "  - $o"
  fi
done
EOF_TREE

chmod +x "$BASE/ds-module-tree.sh"
log "Created ds-module-tree.sh"

# =============================================================================
step "4/5 — Writing ds-module-docs.sh"
# =============================================================================
cat > "$BASE/ds-module-docs.sh" << 'EOF_DOCS'
#!/usr/bin/env bash
# =============================================================================
#  ds-module-docs.sh
#  Auto-generates simple Markdown docs for each ds-* script.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
DOCS_DIR="$ROOT/docs/modules"

G='\033[1;32m'; N='\033[0m'
log() { echo -e "${G}[DOCS]${N} $*"; }

mkdir -p "$DOCS_DIR"

log "Generating module docs into: $DOCS_DIR"

find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | while read -r f; do
  name="$(basename "$f")"
  out="$DOCS_DIR/${name%.sh}.md"
  log "Doc: $name → $(basename "$out")"

  {
    echo "# $name"
    echo ""
    echo "Path: \`$f\`"
    echo ""
    echo "## Description"
    head -5 "$f" | sed 's/^/# /' | sed 's/^# # /- /'
    echo ""
    echo "## Usage"
    echo "\`$name\`"
  } > "$out"
done

log "Docs generation complete."
EOF_DOCS

chmod +x "$BASE/ds-module-docs.sh"
log "Created ds-module-docs.sh"

# =============================================================================
step "5/5 — Writing ds-module-search.sh"
# =============================================================================
cat > "$BASE/ds-module-search.sh" << 'EOF_SEARCH'
#!/usr/bin/env bash
# =============================================================================
#  ds-module-search.sh
#  Fuzzy search across module names and docs.
#
#  Usage:
#    ds-module-search.sh <pattern>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
DOCS_DIR="$ROOT/docs/modules"

G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'
log()  { echo -e "${G}[SEARCH]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }

pattern="${1:-}"
[[ -z "$pattern" ]] && { warn "Usage: $0 <pattern>"; exit 1; }

log "Searching scripts for: $pattern"
find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" -print | grep -i "$pattern" || warn "No script name matches."

if [[ -d "$DOCS_DIR" ]]; then
  log "Searching docs for: $pattern"
  grep -RIn "$pattern" "$DOCS_DIR" || warn "No doc content matches."
else
  warn "Docs directory not found: $DOCS_DIR"
fi
EOF_SEARCH

chmod +x "$BASE/ds-module-search.sh"
log "Created ds-module-search.sh"

# =============================================================================
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Module Framework Suite Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
