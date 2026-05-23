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
