#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Next Tier Module Suite Generator
#
#  Creates:
#    - ds-module-categories.sh      (auto-categorize modules)
#    - ds-module-deps.sh            (dependency graph scanner)
#    - ds-module-versioning.sh      (simple version/changelog system)
#    - ds-module-installer.sh       (install/enable/disable modules)
#    - ds-module-sandbox-suite.sh   (permission model for modules)
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
step "1/5 — Writing ds-module-categories.sh"
# =============================================================================
cat > "$BASE/ds-module-categories.sh" << 'EOF_CAT'
#!/usr/bin/env bash
# =============================================================================
#  ds-module-categories.sh
#  Auto-categorizes modules based on name patterns and metadata.
#
#  Output:
#    ~/DroidShell/registry/categories.txt
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
REG="$ROOT/registry/categories.txt"

G='\033[1;32m'; N='\033[0m'
log() { echo -e "${G}[CATS]${N} $*"; }

mkdir -p "$(dirname "$REG")"

log "Building category map at: $REG"

{
  echo "# Module Categories"
  echo "# name|category"
  echo "# Generated: $(date)"
  echo ""

  find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | while read -r f; do
    name="$(basename "$f")"
    cat="misc"

    case "$name" in
      ds-ecosystem*|ds-bundle-ecosystem*|ds-ecosystem-master.sh)
        cat="ecosystem"
        ;;
      ds-bundle-services*|ds-services*|ds-service-*|ds-service-manager.sh)
        cat="services"
        ;;
      ds-bundle-runtime*|ds-runtime*|ds-os.sh)
        cat="runtime"
        ;;
      ds-root-*|ds_root_*|ds-magisk-*|ds-magisk-*)
        cat="root"
        ;;
      ds-ota-*|ds-update-*|ds-updater-*|ds-qr-install*|ds-qr-installer*)
        cat="ota"
        ;;
      ds-build-*|ds-release-*|ds-sign-*|ds-verify-*|ds-version.sh)
        cat="build-release"
        ;;
      ds-api-*|ds-site-*|ds-docs-*|ds-api-docs.sh|ds-api-server.sh)
        cat="api-web"
        ;;
      ds-plugin-*|ds-sdk-*|ds-sandbox.sh)
        cat="plugins"
        ;;
      ds-health.sh|ds-doctor.sh|ds-system-audit.sh|ds-self-heal.sh|ds-bootstrap-all.sh)
        cat="health"
        ;;
      ds-module-*|ds-generate-*|ds-rename-*|ds-cleanup-*|ds-lint-*|ds-fix-*|ds-bootstrap-*|ds-release-master.sh)
        cat="framework"
        ;;
    esac

    echo "${name}|${cat}"
  done
} > "$REG"

log "Categories written."
EOF_CAT

chmod +x "$BASE/ds-module-categories.sh"
log "Created ds-module-categories.sh"

# =============================================================================
step "2/5 — Writing ds-module-deps.sh"
# =============================================================================
cat > "$BASE/ds-module-deps.sh" << 'EOF_DEPS'
#!/usr/bin/env bash
# =============================================================================
#  ds-module-deps.sh
#  Builds a simple dependency graph based on script-to-script calls.
#
#  Output:
#    ~/DroidShell/registry/deps.txt
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
REG="$ROOT/registry/deps.txt"

G='\033[1;32m'; N='\033[0m'
log() { echo -e "${G}[DEPS]${N} $*"; }

mkdir -p "$(dirname "$REG")"

log "Building dependency graph at: $REG"

{
  echo "# Module Dependencies"
  echo "# from|to"
  echo "# Generated: $(date)"
  echo ""

  find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | while read -r f; do
    from="$(basename "$f")"
    # look for calls to other ds-*.sh scripts
    grep -oE 'ds-[a-zA-Z0-9_-]+\.sh' "$f" 2>/dev/null | sort -u | while read -r callee; do
      [[ "$callee" == "$from" ]] && continue
      echo "${from}|${callee}"
    done
  done
} > "$REG"

log "Dependency graph written."
EOF_DEPS

chmod +x "$BASE/ds-module-deps.sh"
log "Created ds-module-deps.sh"

# =============================================================================
step "3/5 — Writing ds-module-versioning.sh"
# =============================================================================
cat > "$BASE/ds-module-versioning.sh" << 'EOF_VER'
#!/usr/bin/env bash
# =============================================================================
#  ds-module-versioning.sh
#  Simple per-module version + changelog system.
#
#  Usage:
#    ds-module-versioning.sh bump <script> <major|minor|patch> [message]
#    ds-module-versioning.sh show <script>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
VER_DIR="$ROOT/registry/versions"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[VER]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
err()  { echo -e "${R}[ERR]${N} $*"; exit 1; }

mkdir -p "$VER_DIR"

cmd="${1:-}"; shift || true

ver_file_for() {
  local script="$1"
  local base
  base="$(basename "$script")"
  echo "$VER_DIR/${base}.ver"
}

bump_version() {
  local old="$1" part="$2"
  local major minor patch
  IFS='.' read -r major minor patch <<< "${old:-0.0.0}"
  case "$part" in
    major) major=$((major+1)); minor=0; patch=0 ;;
    minor) minor=$((minor+1)); patch=0 ;;
    patch) patch=$((patch+1)) ;;
    *) err "Unknown part: $part" ;;
  esac
  echo "${major}.${minor}.${patch}"
}

case "$cmd" in
  bump)
    script="${1:-}"; part="${2:-}"; msg="${3:-no message}"
    [[ -z "$script" || -z "$part" ]] && err "Usage: bump <script> <major|minor|patch> [message]"
    vf="$(ver_file_for "$script")"
    old_ver="0.0.0"
    [[ -f "$vf" ]] && old_ver="$(head -1 "$vf" | awk '{print $2}' || echo "0.0.0")"
    new_ver="$(bump_version "$old_ver" "$part")"
    {
      echo "version $new_ver $(date)"
      echo "- $msg"
      echo ""
      [[ -f "$vf" ]] && tail -n +3 "$vf" || true
    } > "${vf}.tmp"
    mv "${vf}.tmp" "$vf"
    log "Bumped $(basename "$script") from $old_ver to $new_ver"
    ;;
  show)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: show <script>"
    vf="$(ver_file_for "$script")"
    [[ -f "$vf" ]] || { warn "No version info for $script"; exit 0; }
    cat "$vf"
    ;;
  *)
    err "Usage: $0 {bump|show} ..."
    ;;
esac
EOF_VER

chmod +x "$BASE/ds-module-versioning.sh"
log "Created ds-module-versioning.sh"

# =============================================================================
step "4/5 — Writing ds-module-installer.sh"
# =============================================================================
cat > "$BASE/ds-module-installer.sh" << 'EOF_INST'
#!/usr/bin/env bash
# =============================================================================
#  ds-module-installer.sh
#  Simple module install/enable/disable system.
#
#  Usage:
#    ds-module-installer.sh list
#    ds-module-installer.sh enable <script>
#    ds-module-installer.sh disable <script>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
STATE_DIR="$ROOT/registry/state"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[INST]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
err()  { echo -e "${R}[ERR]${N} $*"; exit 1; }

mkdir -p "$STATE_DIR"

cmd="${1:-}"; shift || true

state_file_for() {
  local script="$1"
  local base
  base="$(basename "$script")"
  echo "$STATE_DIR/${base}.state"
}

case "$cmd" in
  list)
    find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | while read -r f; do
      base="$(basename "$f")"
      sf="$(state_file_for "$base")"
      state="enabled"
      [[ -f "$sf" ]] && state="$(cat "$sf")"
      printf "%-40s %s\n" "$base" "$state"
    done
    ;;
  enable)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: enable <script>"
    sf="$(state_file_for "$script")"
    echo "enabled" > "$sf"
    log "Enabled $script"
    ;;
  disable)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: disable <script>"
    sf="$(state_file_for "$script")"
    echo "disabled" > "$sf"
    log "Disabled $script"
    ;;
  *)
    err "Usage: $0 {list|enable|disable} ..."
    ;;
esac
EOF_INST

chmod +x "$BASE/ds-module-installer.sh"
log "Created ds-module-installer.sh"

# =============================================================================
step "5/5 — Writing ds-module-sandbox-suite.sh"
# =============================================================================
cat > "$BASE/ds-module-sandbox-suite.sh" << 'EOF_SBOX'
#!/usr/bin/env bash
# =============================================================================
#  ds-module-sandbox-suite.sh
#  Simple permission model for modules (allow-net, allow-root, allow-fs, allow-exec).
#
#  Usage:
#    ds-module-sandbox-suite.sh set <script> <perm> <on|off>
#    ds-module-sandbox-suite.sh show <script>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SBOX_DIR="$ROOT/registry/sandbox"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[SBOX]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
err()  { echo -e "${R}[ERR]${N} $*"; exit 1; }

mkdir -p "$SBOX_DIR"

cmd="${1:-}"; shift || true

sbox_file_for() {
  local script="$1"
  local base
  base="$(basename "$script")"
  echo "$SBOX_DIR/${base}.perm"
}

case "$cmd" in
  set)
    script="${1:-}"; perm="${2:-}"; val="${3:-}"
    [[ -z "$script" || -z "$perm" || -z "$val" ]] && err "Usage: set <script> <perm> <on|off>"
    sf="$(sbox_file_for "$script")"
    touch "$sf"
    grep -v "^${perm}=" "$sf" 2>/dev/null > "${sf}.tmp" || true
    echo "${perm}=${val}" >> "${sf}.tmp"
    mv "${sf}.tmp" "$sf"
    log "Set ${perm}=${val} for $(basename "$script")"
    ;;
  show)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: show <script>"
    sf="$(sbox_file_for "$script")"
    [[ -f "$sf" ]] || { warn "No sandbox config for $script"; exit 0; }
    echo "# Sandbox permissions for $(basename "$script")"
    cat "$sf"
    ;;
  *)
    err "Usage: $0 {set|show} ..."
    ;;
esac
EOF_SBOX

chmod +x "$BASE/ds-module-sandbox-suite.sh"
log "Created ds-module-sandbox-suite.sh"

# =============================================================================
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier Module Suite Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
