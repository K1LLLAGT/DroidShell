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
