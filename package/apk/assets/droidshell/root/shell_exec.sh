#!/usr/bin/env bash
# DroidShell :: root/shell_exec.sh
# Safe wrapper around: su -c "<command>"
# Maintains an audit log with timestamps.
# Usage: shell_exec.sh "<command>"
#        shell_exec.sh --interactive
#        shell_exec.sh --audit-log [<file>]

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'

AUDIT_LOG="${HOME}/DroidShell/logs/shell_exec_audit.log"
INTERACTIVE=false
SHOW_LOG=false

[[ "$1" == "--interactive" ]] && { INTERACTIVE=true; shift || true; }
[[ "$1" == "--audit-log"   ]] && { SHOW_LOG=true;    shift || true
                                   [[ -n "${1:-}" ]] && { AUDIT_LOG="$1"; shift; }; }

mkdir -p "$(dirname "$AUDIT_LOG")"

su -c "id" 2>/dev/null | grep -q "uid=0" || {
  echo -e "${R}[ERR] Root not available${N}" >&2; exit 1; }

$SHOW_LOG && { cat "$AUDIT_LOG" 2>/dev/null || echo "(no audit log yet)"; exit 0; }

_exec_cmd() {
  local cmd="$1"
  local ts; ts="$(date -Iseconds)"
  local caller; caller="$(id -un 2>/dev/null || echo unknown)"

  echo -e "${C}[su-exec]${N} ${cmd}"

  local output exit_code=0
  output=$(su -c "$cmd" 2>&1) || exit_code=$?

  # Audit entry
  printf '%s | caller=%s | exit=%d | cmd=%s\n' \
    "$ts" "$caller" "$exit_code" "$cmd" >> "$AUDIT_LOG"

  if [[ $exit_code -eq 0 ]]; then
    echo -e "${G}[✓ exit:0]${N}"
    echo "$output"
  else
    echo -e "${Y}[! exit:${exit_code}]${N}"
    echo "$output"
  fi
  return $exit_code
}

if $INTERACTIVE; then
  echo -e "${C}DroidShell root shell — type 'exit' to quit${N}"
  echo -e "${Y}All commands are logged to: ${AUDIT_LOG}${N}"
  while IFS= read -r -p "$(echo -e "${R}root${N}${C}@droidshell${N}# ")" line; do
    [[ "$line" == "exit" ]] && break
    [[ -z "$line" ]] && continue
    _exec_cmd "$line" || true
  done
  echo -e "${C}Session ended.${N}"
elif [[ -n "${1:-}" ]]; then
  _exec_cmd "$*"
else
  echo "Usage: shell_exec.sh \"<command>\""
  echo "       shell_exec.sh --interactive"
  echo "       shell_exec.sh --audit-log [<logfile>]"
fi
