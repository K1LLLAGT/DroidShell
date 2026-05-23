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
