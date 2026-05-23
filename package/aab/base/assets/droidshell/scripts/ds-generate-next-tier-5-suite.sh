#!/usr/bin/env bash
# Analytics + Lab Harness
set -euo pipefail
BASE="$HOME/DroidShell/scripts"
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
mkdir -p "$BASE" "$REG"
G='\033[1;32m'; M='\033[1;35m'; N='\033[0m'
log(){ echo -e "${G}[GEN]${N} $*"; }
step(){ echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/6 — Writing ds-telemetry-log.sh"
cat > "$BASE/ds-telemetry-log.sh" << 'EOF_TLOG'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/telemetry.log"
event="${1:-}"; shift || true
[ -z "$event" ] && { echo "Usage: ds-telemetry-log.sh <event> [key=value ...]"; exit 1; }
echo "$(date +%Y-%m-%dT%H:%M:%S) event=$event $*" >> "$LOG"
EOF_TLOG
chmod +x "$BASE/ds-telemetry-log.sh"
log "Created ds-telemetry-log.sh"

step "2/6 — Writing ds-telemetry-report.sh"
cat > "$BASE/ds-telemetry-report.sh" << 'EOF_TREP'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/telemetry.log"
cmd="${1:-}"; shift || true
case "$cmd" in
  summary)
    [ -f "$LOG" ] || { echo "No telemetry"; exit 0; }
    awk '{for(i=1;i<=NF;i++) if($i ~ /^event=/){sub("event=","",$i); print $i}}' "$LOG" | sort | uniq -c | sort -nr;;
  recent)
    n="${1:-20}"
    [ -f "$LOG" ] && tail -n "$n" "$LOG" || echo "No telemetry";;
  *) echo "Usage: $0 {summary|recent [N]}";;
esac
EOF_TREP
chmod +x "$BASE/ds-telemetry-report.sh"
log "Created ds-telemetry-report.sh"

step "3/6 — Writing ds-crash-log.sh"
cat > "$BASE/ds-crash-log.sh" << 'EOF_CRASH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOG="$ROOT/registry/crash.log"
script="${1:-}"; shift || true
[ -z "$script" ] && { echo "Usage: ds-crash-log.sh <script> [args...]"; exit 1; }
ts="$(date +%Y-%m-%dT%H:%M:%S)"
bash "$ROOT/scripts/$script" "$@"
status=$?
[ $status -ne 0 ] && echo "$ts script=$script status=$status args=\"$*\"" >> "$LOG"
exit $status
EOF_CRASH
chmod +x "$BASE/ds-crash-log.sh"
log "Created ds-crash-log.sh"

step "4/6 — Writing ds-lab-snapshot-env.sh"
cat > "$BASE/ds-lab-snapshot-env.sh" << 'EOF_LSNAP'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
name="${1:-}"
[ -z "$name" ] && { echo "Usage: ds-lab-snapshot-env.sh <name>"; exit 1; }
OUT="$REG/lab-env-${name}.snapshot"
{
  echo "# Lab snapshot: $name"
  echo "# Date: $(date)"
  echo "## env"
  env | sort
} > "$OUT"
echo "[LAB] $OUT"
EOF_LSNAP
chmod +x "$BASE/ds-lab-snapshot-env.sh"
log "Created ds-lab-snapshot-env.sh"

step "5/6 — Writing ds-lab-diff-env.sh"
cat > "$BASE/ds-lab-diff-env.sh" << 'EOF_LDIFF'
#!/usr/bin/env bash
set -euo pipefail
a="${1:-}"; b="${2:-}"
[ -z "$a" ] || [ -z "$b" ] && { echo "Usage: ds-lab-diff-env.sh <snapshot-a> <snapshot-b>"; exit 1; }
diff -u "$a" "$b" || { echo "[LAB] Differences"; exit 1; }
echo "[LAB] Identical"
EOF_LDIFF
chmod +x "$BASE/ds-lab-diff-env.sh"
log "Created ds-lab-diff-env.sh"

step "6/6 — Writing ds-lab-harness.sh"
cat > "$BASE/ds-lab-harness.sh" << 'EOF_LH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
label="${1:-}"; shift || true
script="${1:-}"; shift || true
[ -z "$label" ] || [ -z "$script" ] && { echo "Usage: ds-lab-harness.sh <label> <script> [args...]"; exit 1; }
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

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Next Tier 5 (Analytics + Lab Harness) Generated${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
