#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Next Tier 3 Suite Generator
#
#  Axes:
#    - Observability (metrics, timing, history, profiling)
#    - Policy & Safety (guardrails, invariants, preflight, rollback)
#
#  Creates:
#    Observability:
#      - ds-obs-metrics.sh
#      - ds-obs-timing.sh
#      - ds-obs-history.sh
#      - ds-obs-profiler.sh
#
#    Policy & Safety:
#      - ds-policy-guard.sh
#      - ds-policy-invariants.sh
#      - ds-policy-preflight.sh
#      - ds-policy-rollback.sh
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
step "1/8 — Writing ds-obs-metrics.sh"
# =============================================================================
cat > "$BASE/ds-obs-metrics.sh" << 'EOF_METRICS'
#!/usr/bin/env bash
# =============================================================================
#  ds-obs-metrics.sh
#  Simple metrics logger for script runs.
#
#  Usage:
#    ds-obs-metrics.sh log <script> <status>
#    ds-obs-metrics.sh summary
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
METRICS="$ROOT/registry/metrics.log"

G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'
log()  { echo -e "${G}[METRICS]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }

cmd="${1:-}"; shift || true

case "$cmd" in
  log)
    script="${1:-}"; status="${2:-}"
    [[ -z "$script" || -z "$status" ]] && { warn "Usage: log <script> <status>"; exit 1; }
    echo "$(date +%Y-%m-%dT%H:%M:%S) ${script} ${status}" >> "$METRICS"
    ;;
  summary)
    [[ -f "$METRICS" ]] || { warn "No metrics yet"; exit 0; }
    echo "=== Metrics Summary ==="
    awk '{print $2, $3}' "$METRICS" | sort | uniq -c | sort -nr
    ;;
  *)
    echo "Usage: $0 {log|summary} ..."
    ;;
esac
EOF_METRICS

chmod +x "$BASE/ds-obs-metrics.sh"
log "Created ds-obs-metrics.sh"

# =============================================================================
step "2/8 — Writing ds-obs-timing.sh"
# =============================================================================
cat > "$BASE/ds-obs-timing.sh" << 'EOF_TIMING'
#!/usr/bin/env bash
# =============================================================================
#  ds-obs-timing.sh
#  Time wrapper for any ds-* script.
#
#  Usage:
#    ds-obs-timing.sh <script> [args...]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/timing.log"

script="${1:-}"
shift || true

[[ -z "$script" ]] && { echo "Usage: ds-obs-timing.sh <script> [args...]"; exit 1; }

start=$(date +%s)
bash "$HOME/DroidShell/scripts/$script" "$@"
status=$?
end=$(date +%s)
dur=$((end - start))

echo "$(date +%Y-%m-%dT%H:%M:%S) ${script} status=${status} duration=${dur}s" >> "$LOG"
echo "[TIMING] ${script} took ${dur}s (status=${status})"
exit $status
EOF_TIMING

chmod +x "$BASE/ds-obs-timing.sh"
log "Created ds-obs-timing.sh"

# =============================================================================
step "3/8 — Writing ds-obs-history.sh"
# =============================================================================
cat > "$BASE/ds-obs-history.sh" << 'EOF_HISTORY'
#!/usr/bin/env bash
# =============================================================================
#  ds-obs-history.sh
#  Run history viewer for DroidShell scripts.
#
#  Usage:
#    ds-obs-history.sh metrics
#    ds-obs-history.sh timing
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
METRICS="$ROOT/registry/metrics.log"
TIMING="$ROOT/registry/timing.log"

cmd="${1:-}"

case "$cmd" in
  metrics)
    [[ -f "$METRICS" ]] && cat "$METRICS" || echo "[HISTORY] No metrics log"
    ;;
  timing)
    [[ -f "$TIMING" ]] && cat "$TIMING" || echo "[HISTORY] No timing log"
    ;;
  *)
    echo "Usage: $0 {metrics|timing}"
    ;;
esac
EOF_HISTORY

chmod +x "$BASE/ds-obs-history.sh"
log "Created ds-obs-history.sh"

# =============================================================================
step "4/8 — Writing ds-obs-profiler.sh"
# =============================================================================
cat > "$BASE/ds-obs-profiler.sh" << 'EOF_PROF'
#!/usr/bin/env bash
# =============================================================================
#  ds-obs-profiler.sh
#  Simple profiler: runs a script N times and reports average duration.
#
#  Usage:
#    ds-obs-profiler.sh <script> <count> [args...]
# =============================================================================

set -euo pipefail

script="${1:-}"
count="${2:-}"
shift 2 || true

[[ -z "$script" || -z "$count" ]] && { echo "Usage: ds-obs-profiler.sh <script> <count> [args...]"; exit 1; }

total=0
for i in $(seq 1 "$count"); do
  start=$(date +%s)
  bash "$HOME/DroidShell/scripts/$script" "$@"
  status=$?
  end=$(date +%s)
  dur=$((end - start))
  echo "[PROF] run $i: ${dur}s (status=${status})"
  total=$((total + dur))
done

avg=$((total / count))
echo "[PROF] average over ${count} runs: ${avg}s"
EOF_PROF

chmod +x "$BASE/ds-obs-profiler.sh"
log "Created ds-obs-profiler.sh"

# =============================================================================
step "5/8 — Writing ds-policy-guard.sh"
# =============================================================================
cat > "$BASE/ds-policy-guard.sh" << 'EOF_GUARD'
#!/usr/bin/env bash
# =============================================================================
#  ds-policy-guard.sh
#  Central guardrail checker for modules.
#
#  Usage:
#    ds-policy-guard.sh check <script>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SBOX_DIR="$ROOT/registry/sandbox"
STATE_DIR="$ROOT/registry/state"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[GUARD]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
err()  { echo -e "${R}[DENY]${N} $*"; exit 1; }

cmd="${1:-}"; shift || true

perm_file_for() {
  local script="$1"
  echo "$SBOX_DIR/$(basename "$script").perm"
}

state_file_for() {
  local script="$1"
  echo "$STATE_DIR/$(basename "$script").state"
}

case "$cmd" in
  check)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: check <script>"

    sf="$(state_file_for "$script")"
    if [[ -f "$sf" ]]; then
      state="$(cat "$sf")"
      [[ "$state" == "disabled" ]] && err "$script is disabled by policy"
    fi

    pf="$(perm_file_for "$script")"
    if [[ -f "$pf" ]]; then
      log "Permissions for $script:"
      cat "$pf"
    else
      warn "No sandbox config for $script (default allow)"
    fi
    ;;
  *)
    echo "Usage: $0 check <script>"
    ;;
esac
EOF_GUARD

chmod +x "$BASE/ds-policy-guard.sh"
log "Created ds-policy-guard.sh"

# =============================================================================
step "6/8 — Writing ds-policy-invariants.sh"
# =============================================================================
cat > "$BASE/ds-policy-invariants.sh" << 'EOF_INV'
#!/usr/bin/env bash
# =============================================================================
#  ds-policy-invariants.sh
#  Checks core invariants of the DroidShell environment.
#
#  Usage:
#    ds-policy-invariants.sh
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

G='\033[1;32m'; R='\033[1;31m'; N='\033[0m'
log() { echo -e "${G}[INV]${N} $*"; }
err() { echo -e "${R}[FAIL]${N} $*"; exit 1; }

check_dir() {
  [[ -d "$1" ]] || err "Missing required directory: $1"
}

check_file() {
  [[ -f "$1" ]] || err "Missing required file: $1"
}

log "Checking invariants…"

check_dir "$ROOT/scripts"
check_dir "$ROOT/registry"
check_file "$ROOT/scripts/ds-bootstrap-all.sh"
check_file "$ROOT/scripts/ds-self-heal.sh"

log "All invariants satisfied."
EOF_INV

chmod +x "$BASE/ds-policy-invariants.sh"
log "Created ds-policy-invariants.sh"

# =============================================================================
step "7/8 — Writing ds-policy-preflight.sh"
# =============================================================================
cat > "$BASE/ds-policy-preflight.sh" << 'EOF_PREFLIGHT'
#!/usr/bin/env bash
# =============================================================================
#  ds-policy-preflight.sh
#  Preflight checker before running critical operations.
#
#  Usage:
#    ds-policy-preflight.sh <operation>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

op="${1:-}"

[[ -z "$op" ]] && { echo "Usage: ds-policy-preflight.sh <operation>"; exit 1; }

echo "[PREFLIGHT] Operation: $op"

bash "$ROOT/scripts/ds-policy-invariants.sh"

case "$op" in
  release)
    [[ -f "$ROOT/VERSION" ]] || { echo "[PREFLIGHT] Missing VERSION"; exit 1; }
    ;;
  bootstrap|fix|heal)
    ;;
  *)
    ;;
esac

echo "[PREFLIGHT] OK"
EOF_PREFLIGHT

chmod +x "$BASE/ds-policy-preflight.sh"
log "Created ds-policy-preflight.sh"

# =============================================================================
step "8/8 — Writing ds-policy-rollback.sh"
# =============================================================================
cat > "$BASE/ds-policy-rollback.sh" << 'EOF_ROLL'
#!/usr/bin/env bash
# =============================================================================
#  ds-policy-rollback.sh
#  Simple rollback helper using git (if repo is under git).
#
#  Usage:
#    ds-policy-rollback.sh last
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

cmd="${1:-}"

case "$cmd" in
  last)
    cd "$ROOT"
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      echo "[ROLLBACK] Resetting to HEAD~1"
      git reset --hard HEAD~1
    else
      echo "[ROLLBACK] Not a git repo"
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 last"
    ;;
esac
EOF_ROLL

chmod +x "$BASE/ds-policy-rollback.sh"
log "Created ds-policy-rollback.sh"

# =============================================================================
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 3 (Observability + Policy/Safety) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
