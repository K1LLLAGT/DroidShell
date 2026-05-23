#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Next Tier 4 Suite Generator
#
#  Axes:
#    - Auto-update & distribution hardening
#    - Background integrity / watchdog
#
#  Creates:
#    Auto-update / Hardening:
#      - ds-auto-update.sh
#      - ds-auto-hardening.sh
#      - ds-auto-sync.sh
#
#    Background integrity / Watchdog:
#      - ds-integrity-snapshot.sh
#      - ds-integrity-compare.sh
#      - ds-integrity-daemon.sh
#
#  Output directory:
#    ~/DroidShell/scripts/
# =============================================================================

set -euo pipefail

BASE="$HOME/DroidShell/scripts"
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
mkdir -p "$BASE" "$REG"

G='\033[1;32m'; M='\033[1;35m'; Y='\033[1;33m'; N='\033[0m'
log()  { echo -e "${G}[GEN]${N} $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

# =============================================================================
step "1/6 — Writing ds-auto-update.sh"
# =============================================================================
cat > "$BASE/ds-auto-update.sh" << 'EOF_AUTO_UPDATE'
#!/usr/bin/env bash
# =============================================================================
#  ds-auto-update.sh
#  Pulls latest changes from git and runs bootstrap.
#
#  Usage:
#    ds-auto-update.sh
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

cd "$ROOT"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[AUTO-UPDATE] Fetching latest…"
  git pull --rebase
else
  echo "[AUTO-UPDATE] Not a git repo"
  exit 1
fi

if [[ -x "$ROOT/scripts/ds-bootstrap-all.sh" ]]; then
  echo "[AUTO-UPDATE] Running bootstrap…"
  "$ROOT/scripts/ds-bootstrap-all.sh"
fi

echo "[AUTO-UPDATE] Done."
EOF_AUTO_UPDATE

chmod +x "$BASE/ds-auto-update.sh"
log "Created ds-auto-update.sh"

# =============================================================================
step "2/6 — Writing ds-auto-hardening.sh"
# =============================================================================
cat > "$BASE/ds-auto-hardening.sh" << 'EOF_HARDEN'
#!/usr/bin/env bash
# =============================================================================
#  ds-auto-hardening.sh
#  Applies basic hardening to the DroidShell tree.
#
#  - Tightens permissions on scripts and registry
#  - Ensures no world-writable files
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

echo "[HARDEN] Tightening script permissions…"
find "$ROOT/scripts" -type f -name "*.sh" -exec chmod 750 {} \;

echo "[HARDEN] Tightening registry permissions…"
chmod -R 700 "$ROOT/registry"

echo "[HARDEN] Checking for world-writable files…"
WW=$(find "$ROOT" -perm -0002 -type f || true)
if [[ -n "$WW" ]]; then
  echo "[HARDEN] WARNING: world-writable files detected:"
  echo "$WW"
else
  echo "[HARDEN] No world-writable files."
fi

echo "[HARDEN] Done."
EOF_HARDEN

chmod +x "$BASE/ds-auto-hardening.sh"
log "Created ds-auto-hardening.sh"

# =============================================================================
step "3/6 — Writing ds-auto-sync.sh"
# =============================================================================
cat > "$BASE/ds-auto-sync.sh" << 'EOF_SYNC'
#!/usr/bin/env bash
# =============================================================================
#  ds-auto-sync.sh
#  Simple sync helper (e.g., to a remote backup via git or rsync).
#
#  Usage:
#    ds-auto-sync.sh [remote]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
REMOTE="${1:-origin}"

cd "$ROOT"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[AUTO-SYNC] Committing and pushing to $REMOTE"
  git add -A
  git commit -m "Auto-sync $(date +%Y-%m-%dT%H:%M:%S)" || echo "[AUTO-SYNC] Nothing to commit"
  git push "$REMOTE" HEAD || echo "[AUTO-SYNC] Push failed"
else
  echo "[AUTO-SYNC] Not a git repo"
  exit 1
fi
EOF_SYNC

chmod +x "$BASE/ds-auto-sync.sh"
log "Created ds-auto-sync.sh"

# =============================================================================
step "4/6 — Writing ds-integrity-snapshot.sh"
# =============================================================================
cat > "$BASE/ds-integrity-snapshot.sh" << 'EOF_SNAP'
#!/usr/bin/env bash
# =============================================================================
#  ds-integrity-snapshot.sh
#  Takes a snapshot of file checksums for later comparison.
#
#  Output:
#    registry/integrity.snapshot
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/registry/integrity.snapshot"

echo "[INTEGRITY] Creating snapshot at: $OUT"

cd "$ROOT"
find . -type f \
  ! -path "./.git/*" \
  ! -path "./out/*" \
  -print0 | sort -z | xargs -0 sha256sum > "$OUT"

echo "[INTEGRITY] Snapshot complete."
EOF_SNAP

chmod +x "$BASE/ds-integrity-snapshot.sh"
log "Created ds-integrity-snapshot.sh"

# =============================================================================
step "5/6 — Writing ds-integrity-compare.sh"
# =============================================================================
cat > "$BASE/ds-integrity-compare.sh" << 'EOF_COMPARE'
#!/usr/bin/env bash
# =============================================================================
#  ds-integrity-compare.sh
#  Compares current tree against saved snapshot.
#
#  Usage:
#    ds-integrity-compare.sh
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SNAP="$ROOT/registry/integrity.snapshot"

[[ -f "$SNAP" ]] || { echo "[INTEGRITY] No snapshot found"; exit 1; }

cd "$ROOT"

echo "[INTEGRITY] Comparing against snapshot…"

TMP=$(mktemp)
find . -type f \
  ! -path "./.git/*" \
  ! -path "./out/*" \
  -print0 | sort -z | xargs -0 sha256sum > "$TMP"

diff -u "$SNAP" "$TMP" || {
  echo "[INTEGRITY] Differences detected."
  rm -f "$TMP"
  exit 1
}

rm -f "$TMP"
echo "[INTEGRITY] No differences."
EOF_COMPARE

chmod +x "$BASE/ds-integrity-compare.sh"
log "Created ds-integrity-compare.sh"

# =============================================================================
step "6/6 — Writing ds-integrity-daemon.sh"
# =============================================================================
cat > "$BASE/ds-integrity-daemon.sh" << 'EOF_DAEMON'
#!/usr/bin/env bash
# =============================================================================
#  ds-integrity-daemon.sh
#  Simple looped integrity checker (foreground daemon-style).
#
#  Usage:
#    ds-integrity-daemon.sh <interval-seconds>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
INTERVAL="${1:-300}"

[[ -f "$ROOT/registry/integrity.snapshot" ]] || {
  echo "[INTEGRITY-DAEMON] No snapshot found, creating one…"
  "$ROOT/scripts/ds-integrity-snapshot.sh"
}

echo "[INTEGRITY-DAEMON] Starting, interval=${INTERVAL}s"

while true; do
  ts=$(date +%Y-%m-%dT%H:%M:%S)
  echo "[INTEGRITY-DAEMON] [$ts] Running compare…"
  if "$ROOT/scripts/ds-integrity-compare.sh"; then
    echo "[INTEGRITY-DAEMON] OK"
  else
    echo "[INTEGRITY-DAEMON] WARNING: integrity mismatch"
  fi
  sleep "$INTERVAL"
done
EOF_DAEMON

chmod +x "$BASE/ds-integrity-daemon.sh"
log "Created ds-integrity-daemon.sh"

# =============================================================================
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 4 (Auto-update + Integrity) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
