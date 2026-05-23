#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Next Tier 2 Suite Generator
#
#  Creates:
#    Distribution:
#      - ds-dist-export.sh
#      - ds-dist-import.sh
#      - ds-dist-profile.sh
#      - ds-dist-preset.sh
#
#    Developer UX:
#      - ds-dev-tui.sh
#      - ds-dev-launcher.sh
#      - ds-dev-help.sh
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
step "1/7 — Writing ds-dist-export.sh"
# =============================================================================
cat > "$BASE/ds-dist-export.sh" << 'EOF_EXPORT'
#!/usr/bin/env bash
# =============================================================================
#  ds-dist-export.sh
#  Exports a full DroidShell environment into a portable archive.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/out/droidshell-export-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "[EXPORT] Creating archive: $OUT"
tar -czf "$OUT" \
  --exclude="out/*.tar.gz" \
  --exclude="registry/versions/*.tmp" \
  -C "$ROOT" .

echo "[EXPORT] Done."
EOF_EXPORT

chmod +x "$BASE/ds-dist-export.sh"
log "Created ds-dist-export.sh"

# =============================================================================
step "2/7 — Writing ds-dist-import.sh"
# =============================================================================
cat > "$BASE/ds-dist-import.sh" << 'EOF_IMPORT'
#!/usr/bin/env bash
# =============================================================================
#  ds-dist-import.sh
#  Imports a DroidShell environment archive.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
ARCHIVE="${1:-}"

[[ -z "$ARCHIVE" ]] && { echo "[IMPORT] Usage: ds-dist-import.sh <archive>"; exit 1; }

echo "[IMPORT] Extracting $ARCHIVE → $ROOT"
tar -xzf "$ARCHIVE" -C "$ROOT"

echo "[IMPORT] Done."
EOF_IMPORT

chmod +x "$BASE/ds-dist-import.sh"
log "Created ds-dist-import.sh"

# =============================================================================
step "3/7 — Writing ds-dist-profile.sh"
# =============================================================================
cat > "$BASE/ds-dist-profile.sh" << 'EOF_PROFILE'
#!/usr/bin/env bash
# =============================================================================
#  ds-dist-profile.sh
#  Saves and loads DroidShell profiles (sets of enabled modules).
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
STATE="$ROOT/registry/state"
PROFILES="$ROOT/registry/profiles"

mkdir -p "$PROFILES"

cmd="${1:-}"

case "$cmd" in
  save)
    name="${2:-}"
    [[ -z "$name" ]] && { echo "Usage: save <name>"; exit 1; }
    cp -r "$STATE" "$PROFILES/$name"
    echo "[PROFILE] Saved profile: $name"
    ;;
  load)
    name="${2:-}"
    [[ -z "$name" ]] && { echo "Usage: load <name>"; exit 1; }
    cp -r "$PROFILES/$name" "$STATE"
    echo "[PROFILE] Loaded profile: $name"
    ;;
  list)
    ls "$PROFILES"
    ;;
  *)
    echo "Usage: $0 {save|load|list}"
    ;;
esac
EOF_PROFILE

chmod +x "$BASE/ds-dist-profile.sh"
log "Created ds-dist-profile.sh"

# =============================================================================
step "4/7 — Writing ds-dist-preset.sh"
# =============================================================================
cat > "$BASE/ds-dist-preset.sh" << 'EOF_PRESET'
#!/usr/bin/env bash
# =============================================================================
#  ds-dist-preset.sh
#  Applies predefined DroidShell presets (minimal, full, dev, root).
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
STATE="$ROOT/registry/state"

mkdir -p "$STATE"

preset="${1:-}"

case "$preset" in
  minimal)
    echo "[PRESET] Applying minimal preset"
    find "$STATE" -type f -delete
    ;;
  full)
    echo "[PRESET] Enabling all modules"
    find "$ROOT/scripts" -maxdepth 1 -type f -name "ds-*.sh" | while read -r f; do
      echo "enabled" > "$STATE/$(basename "$f").state"
    done
    ;;
  dev)
    echo "[PRESET] Developer preset"
    echo "enabled" > "$STATE/ds-dev-tui.sh.state"
    echo "enabled" > "$STATE/ds-dev-launcher.sh.state"
    ;;
  root)
    echo "[PRESET] Root preset"
    find "$ROOT/scripts" -maxdepth 1 -type f -name "ds-root-*.sh" | while read -r f; do
      echo "enabled" > "$STATE/$(basename "$f").state"
    done
    ;;
  *)
    echo "Usage: $0 {minimal|full|dev|root}"
    ;;
esac
EOF_PRESET

chmod +x "$BASE/ds-dist-preset.sh"
log "Created ds-dist-preset.sh"

# =============================================================================
step "5/7 — Writing ds-dev-tui.sh"
# =============================================================================
cat > "$BASE/ds-dev-tui.sh" << 'EOF_TUI'
#!/usr/bin/env bash
# =============================================================================
#  ds-dev-tui.sh
#  Interactive TUI for browsing and running modules.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell/scripts"

while true; do
  clear
  echo "=== DroidShell Developer TUI ==="
  echo ""
  select f in $(ls "$ROOT"/ds-*.sh) "Exit"; do
    case "$f" in
      Exit) exit 0 ;;
      *) bash "$f"; break ;;
    esac
  done
done
EOF_TUI

chmod +x "$BASE/ds-dev-tui.sh"
log "Created ds-dev-tui.sh"

# =============================================================================
step "6/7 — Writing ds-dev-launcher.sh"
# =============================================================================
cat > "$BASE/ds-dev-launcher.sh" << 'EOF_LAUNCH'
#!/usr/bin/env bash
# =============================================================================
#  ds-dev-launcher.sh
#  Fuzzy launcher for modules.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell/scripts"

pattern="${1:-}"

[[ -z "$pattern" ]] && { echo "Usage: ds-dev-launcher.sh <pattern>"; exit 1; }

match=$(ls "$ROOT"/ds-*.sh | grep -i "$pattern" | head -1)

[[ -z "$match" ]] && { echo "[LAUNCH] No match"; exit 1; }

echo "[LAUNCH] Running: $(basename "$match")"
bash "$match"
EOF_LAUNCH

chmod +x "$BASE/ds-dev-launcher.sh"
log "Created ds-dev-launcher.sh"

# =============================================================================
step "7/7 — Writing ds-dev-help.sh"
# =============================================================================
cat > "$BASE/ds-dev-help.sh" << 'EOF_HELP'
#!/usr/bin/env bash
# =============================================================================
#  ds-dev-help.sh
#  Shows help for any module by printing its header block.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell/scripts"
script="${1:-}"

[[ -z "$script" ]] && { echo "Usage: ds-dev-help.sh <script>"; exit 1; }

file="$ROOT/$script"

[[ ! -f "$file" ]] && { echo "[HELP] Script not found"; exit 1; }

echo "=== Help: $script ==="
grep -E '^#' "$file"
EOF_HELP

chmod +x "$BASE/ds-dev-help.sh"
log "Created ds-dev-help.sh"

# =============================================================================
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 2 (Distribution + Developer UX) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
