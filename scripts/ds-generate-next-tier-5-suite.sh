#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Next Tier 5 Suite Generator
#
#  Axes:
#    - Advanced analytics / telemetry
#    - Lab / experimentation harness
#
#  Creates:
#    Analytics / Telemetry:
#      - ds-telemetry-log.sh
#      - ds-telemetry-report.sh
#      - ds-crash-log.sh
#
#    Lab / Experimentation:
#      - ds-lab-snapshot-env.sh
#      - ds-lab-diff-env.sh
#      - ds-lab-harness.sh
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
step "1/6 — Writing ds-telemetry-log.sh"
# =============================================================================
cat > "$BASE/ds-telemetry-log.sh" << 'EOF_TLOG'
#!/usr/bin/env bash
# =============================================================================
#  ds-telemetry-log.sh
#  Central telemetry logger for arbitrary key/value events.
#
#  Usage:
#    ds-telemetry-log.sh <event> [key=value ...]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/telemetry.log"

event="${1:-}"; shift || true
[[ -z "$event" ]] && { echo "Usage: ds-telemetry-log.sh <event> [key=value ...]"; exit 1; }

ts="$(date +%Y-%m-%dT%H:%M:%S)"
echo "$ts event=$event $*" >> "$LOG"
echo "[TELEMETRY] $ts event=$event $*"
EOF_TLOG

chmod +x "$BASE/ds-telemetry-log.sh"
log "Created ds-telemetry-log.sh"

# =============================================================================
step "2/6 — Writing ds-telemetry-report.sh"
# =============================================================================
cat > "$BASE/ds-telemetry-report.sh" << 'EOF_TREP'
#!/usr/bin/env bash
# =============================================================================
#  ds-telemetry-report.sh
#  Simple telemetry reporter (event counts, recent events).
#
#  Usage:
#    ds-telemetry-report.sh summary
#    ds-telemetry-report.sh recent [N]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/telemetry.log"

cmd="${1:-}"; shift || true

case "$cmd" in
  summary)
    [[ -f "$LOG" ]] || { echo "[TELEMETRY] No telemetry log"; exit 0; }
    echo "=== Telemetry Event Counts ==="
    awk '{for(i=1;i<=NF;i++) if($i ~ /^event=/){sub("event=","",$i); print $i}}' "$LOG" \
      | sort | uniq -c | sort -nr
    ;;
  recent)
    n="${1:-20}"
    [[ -f "$LOG" ]] || { echo "[TELEMETRY] No telemetry log"; exit 0; }
    echo "=== Last $n Telemetry Events ==="
    tail -n "$n" "$LOG"
    ;;
  *)
    echo "Usage: $0 {summary|recent [N]}"
    ;;
esac
EOF_TREP

chmod +x "$BASE/ds-telemetry-report.sh"
log "Created ds-telemetry-report.sh"

# =============================================================================
step "3/6 — Writing ds-crash-log.sh"
# =============================================================================
cat > "$BASE/ds-crash-log.sh" << 'EOF_CRASH'
#!/usr/bin/env bash
# =============================================================================
#  ds-crash-log.sh
#  Wrapper to run a script and log crashes/non-zero exits.
#
#  Usage:
#    ds-crash-log.sh <script> [args...]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/crash.log"

script="${1:-}"; shift || true
[[ -z "$script" ]] && { echo "Usage: ds-crash-log.sh <script> [args...]"; exit 1; }

ts="$(date +%Y-%m-%dT%H:%M:%S)"
bash "$ROOT/scripts/$script" "$@"
status=$?

if [[ $status -ne 0 ]]; then
  echo "$ts script=$script status=$status args=\"$*\"" >> "$LOG"
  echo "[CRASH] Logged failure for $script (status=$status)"
fi

exit $status
EOF_CRASH

chmod +x "$BASE/ds-crash-log.sh"
log "Created ds-crash-log.sh"

# =============================================================================
step "4/6 — Writing ds-lab-snapshot-env.sh"
# =============================================================================
cat > "$BASE/ds-lab-snapshot-env.sh" << 'EOF_LSNAP'
#!/usr/bin/env bash
# =============================================================================
#  ds-lab-snapshot-env.sh
#  Captures an environment snapshot for lab/experiment reproducibility.
#
#  Output:
#    registry/lab-env-<name>.snapshot
#
#  Usage:
#    ds-lab-snapshot-env.sh <name>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
REG="$ROOT/registry"

name="${1:-}"
[[ -z "$name" ]] && { echo "Usage: ds-lab-snapshot-env.sh <name>"; exit 1; }

OUT="$REG/lab-env-${name}.snapshot"

{
  echo "# DroidShell Lab Environment Snapshot: $name"
  echo "# Date: $(date)"
  echo ""
  echo "## uname -a"
  uname -a
  echo ""
  echo "## env"
  env | sort
  echo ""
  echo "## scripts checksum"
  (cd "$ROOT" && find scripts -type f -name "ds-*.sh" -print0 | sort -z | xargs -0 sha256sum)
} > "$OUT"

echo "[LAB] Environment snapshot written: $OUT"
EOF_LSNAP

chmod +x "$BASE/ds-lab-snapshot-env.sh"
log "Created ds-lab-snapshot-env.sh"

# =============================================================================
step "5/6 — Writing ds-lab-diff-env.sh"
# =============================================================================
cat > "$BASE/ds-lab-diff-env.sh" << 'EOF_LDIFF'
#!/usr/bin/env bash
# =============================================================================
#  ds-lab-diff-env.sh
#  Compares two lab environment snapshots.
#
#  Usage:
#    ds-lab-diff-env.sh <snapshot-a> <snapshot-b>
# =============================================================================

set -euo pipefail

a="${1:-}"
b="${2:-}"

[[ -z "$a" || -z "$b" ]] && { echo "Usage: ds-lab-diff-env.sh <snapshot-a> <snapshot-b>"; exit 1; }

diff -u "$a" "$b" || {
  echo "[LAB] Differences detected."
  exit 1
}

echo "[LAB] Snapshots are identical."
EOF_LDIFF

chmod +x "$BASE/ds-lab-diff-env.sh"
log "Created ds-lab-diff-env.sh"

# =============================================================================
step "6/6 — Writing ds-lab-harness.sh"
# =============================================================================
cat > "$BASE/ds-lab-harness.sh" << 'EOF_LH'
#!/usr/bin/env bash
# =============================================================================
#  ds-lab-harness.sh
#  Simple experiment harness: run a script under timing + telemetry + crash log.
#
#  Usage:
#    ds-lab-harness.sh <label> <script> [args...]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

label="${1:-}"; shift || true
script="${1:-}"; shift || true

[[ -z "$label" || -z "$script" ]] && {
  echo "Usage: ds-lab-harness.sh <label> <script> [args...]"
  exit 1
}

"$ROOT/scripts/ds-telemetry-log.sh" "lab-start" label="$label" script="$script"
"$ROOT/scripts/ds-obs-timing.sh" "$script" "$@" || {
  "$ROOT/scripts/ds-crash-log.sh" "$script" "$@"
  "$ROOT/scripts/ds-telemetry-log.sh" "lab-fail" label="$label" script="$script"
  exit 1
}
"$ROOT/scripts/ds-telemetry-log.sh" "lab-success" label="$label" script="$script"
EOF_LH

chmod +x "$BASE/ds-lab-harness.sh"
log "Created ds-lab-harness.sh"

# =============================================================================
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 5 (Analytics + Lab Harness) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
