#!/usr/bin/env bash
# DroidShell :: root/proc_inspect.sh
# Full root-mode process enumeration via /proc and ps -ef.
# Usage: proc_inspect.sh [--pid <pid>] [--grep <pattern>] [--out <file>]

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; W='\033[1;37m'; Y='\033[1;33m'; N='\033[0m'

FILTER_PID=""
GREP_PAT=""
OUT_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pid)  FILTER_PID="$2"; shift 2 ;;
    --grep) GREP_PAT="$2";   shift 2 ;;
    --out)  OUT_FILE="$2";   shift 2 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }

inspect_pid() {
  local pid="$1"
  [[ -d "/proc/$pid" ]] || return
  echo -e "\n${C}── PID ${pid} ─────────────────────────────────────${N}"

  local cmdline; cmdline=$(su -c "cat /proc/${pid}/cmdline 2>/dev/null" | tr '\0' ' ' || echo "<kernel>")
  local status;  status=$(su -c  "cat /proc/${pid}/status  2>/dev/null" || echo "n/a")
  local maps_n;  maps_n=$(su -c  "wc -l < /proc/${pid}/maps 2>/dev/null" || echo "0")
  local fds_n;   fds_n=$(su -c   "ls /proc/${pid}/fd 2>/dev/null | wc -l" || echo "0")

  echo -e "  ${W}Cmdline${N} : ${cmdline}"
  echo    "  Status  :"
  echo "$status" | grep -E '^(Name|State|Pid|PPid|Uid|Gid|VmRSS|VmSize|Threads):' \
    | sed 's/^/    /'
  echo -e "  ${W}Maps${N}    : ${maps_n} entries"
  echo -e "  ${W}FDs${N}     : ${fds_n} open"

  # Open files
  echo -e "  ${W}Open FDs${N}:"
  su -c "ls -la /proc/${pid}/fd 2>/dev/null" | head -20 | sed 's/^/    /'

  # Selinux context
  local ctx; ctx=$(su -c "cat /proc/${pid}/attr/current 2>/dev/null" || echo "n/a")
  echo -e "  ${W}SELinux ctx${N}: ${ctx}"
}

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║    DroidShell Process Inspector          ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"

{
  echo "# DroidShell Process Snapshot — $(date -Iseconds)"
  echo ""

  if [[ -n "$FILTER_PID" ]]; then
    inspect_pid "$FILTER_PID"
  else
    echo -e "${C}Full process list (ps -ef):${N}"
    su -c "ps -ef 2>/dev/null || ps -A" | \
      { [[ -n "$GREP_PAT" ]] && grep -E "$GREP_PAT" || cat; }

    echo -e "\n${C}/proc enumeration:${N}"
    for pid in $(su -c "ls /proc" | grep -E '^[0-9]+$'); do
      [[ -n "$GREP_PAT" ]] && {
        su -c "cat /proc/${pid}/cmdline 2>/dev/null" \
          | grep -qE "$GREP_PAT" || continue
      }
      inspect_pid "$pid"
    done
  fi
} | tee "${OUT_FILE:-/dev/null}"

[[ -n "$OUT_FILE" ]] && echo -e "\n${G}[✓] Saved → ${OUT_FILE}${N}"
