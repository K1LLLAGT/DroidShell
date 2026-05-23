#!/usr/bin/env bash
# Observability + Policy/Safety
set -euo pipefail
BASE="$HOME/DroidShell/scripts"
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
mkdir -p "$BASE" "$REG"
G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/8 — Writing ds-obs-metrics.sh"
cat > "$BASE/ds-obs-metrics.sh" << 'EOF_METRICS'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
METRICS="$ROOT/registry/metrics.log"
cmd="${1:-}"; shift || true
case "$cmd" in
  log) script="${1:-}"; status="${2:-}"
       [ -z "$script" ] && exit 1
       echo "$(date +%Y-%m-%dT%H:%M:%S) $script $status" >> "$METRICS";;
  summary)
       [ -f "$METRICS" ] && awk '{print $2, $3}' "$METRICS" | sort | uniq -c | sort -nr || echo "No metrics";;
  *) echo "Usage: $0 {log|summary}";;
esac
EOF_METRICS
chmod +x "$BASE/ds-obs-metrics.sh"
log "Created ds-obs-metrics.sh"

step "2/8 — Writing ds-obs-timing.sh"
cat > "$BASE/ds-obs-timing.sh" << 'EOF_TIMING'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/timing.log"
script="${1:-}"; shift || true
[ -z "$script" ] && { echo "Usage: ds-obs-timing.sh <script> [args...]"; exit 1; }
start=$(date +%s)
bash "$ROOT/scripts/$script" "$@"
status=$?
end=$(date +%s)
dur=$((end-start))
echo "$(date +%Y-%m-%dT%H:%M:%S) $script status=$status duration=${dur}s" >> "$LOG"
echo "[TIMING] $script ${dur}s"
exit $status
EOF_TIMING
chmod +x "$BASE/ds-obs-timing.sh"
log "Created ds-obs-timing.sh"

step "3/8 — Writing ds-obs-history.sh"
cat > "$BASE/ds-obs-history.sh" << 'EOF_HISTORY'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
METRICS="$ROOT/registry/metrics.log"
TIMING="$ROOT/registry/timing.log"
cmd="${1:-}"
case "$cmd" in
  metrics) [ -f "$METRICS" ] && cat "$METRICS" || echo "No metrics";;
  timing)  [ -f "$TIMING" ] && cat "$TIMING" || echo "No timing";;
  *) echo "Usage: $0 {metrics|timing}";;
esac
EOF_HISTORY
chmod +x "$BASE/ds-obs-history.sh"
log "Created ds-obs-history.sh"

step "4/8 — Writing ds-obs-profiler.sh"
cat > "$BASE/ds-obs-profiler.sh" << 'EOF_PROF'
#!/usr/bin/env bash
set -euo pipefail
script="${1:-}"; count="${2:-}"; shift 2 || true
[ -z "$script" ] || [ -z "$count" ] && { echo "Usage: ds-obs-profiler.sh <script> <count> [args...]"; exit 1; }
total=0
for i in $(seq 1 "$count"); do
  start=$(date +%s)
  bash "$HOME/DroidShell/scripts/$script" "$@"
  status=$?
  end=$(date +%s)
  dur=$((end-start))
  echo "[PROF] run $i: ${dur}s (status=$status)"
  total=$((total+dur))
done
avg=$((total/count))
echo "[PROF] average: ${avg}s"
EOF_PROF
chmod +x "$BASE/ds-obs-profiler.sh"
log "Created ds-obs-profiler.sh"

step "5/8 — Writing ds-policy-guard.sh"
cat > "$BASE/ds-policy-guard.sh" << 'EOF_GUARD'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
STATE_DIR="$ROOT/registry/state"
mkdir -p "$STATE_DIR"
cmd="${1:-}"; script="${2:-}"
[ "$cmd" != "check" ] && { echo "Usage: ds-policy-guard.sh check <script>"; exit 1; }
sf="$STATE_DIR/$(basename "$script").state"
[ -f "$sf" ] && [ "$(cat "$sf")" = "disabled" ] && { echo "[GUARD] disabled"; exit 1; }
echo "[GUARD] ok"
EOF_GUARD
chmod +x "$BASE/ds-policy-guard.sh"
log "Created ds-policy-guard.sh"

step "6/8 — Writing ds-policy-invariants.sh"
cat > "$BASE/ds-policy-invariants.sh" << 'EOF_INV'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
[ -d "$ROOT/scripts" ] || { echo "[INV] missing scripts/"; exit 1; }
echo "[INV] OK"
EOF_INV
chmod +x "$BASE/ds-policy-invariants.sh"
log "Created ds-policy-invariants.sh"

step "7/8 — Writing ds-policy-preflight.sh"
cat > "$BASE/ds-policy-preflight.sh" << 'EOF_PREF'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
op="${1:-}"
[ -z "$op" ] && { echo "Usage: ds-policy-preflight.sh <operation>"; exit 1; }
"$ROOT/scripts/ds-policy-invariants.sh"
echo "[PREFLIGHT] OK for $op"
EOF_PREF
chmod +x "$BASE/ds-policy-preflight.sh"
log "Created ds-policy-preflight.sh"

step "8/8 — Writing ds-policy-rollback.sh"
cat > "$BASE/ds-policy-rollback.sh" << 'EOF_ROLL'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
cmd="${1:-}"
case "$cmd" in
  last) cd "$ROOT"
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          git reset --hard HEAD~1
        else
          echo "Not a git repo"; exit 1
        fi;;
  *) echo "Usage: $0 last";;
esac
EOF_ROLL
chmod +x "$BASE/ds-policy-rollback.sh"
log "Created ds-policy-rollback.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 3 (Observability + Policy/Safety) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
