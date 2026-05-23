#!/usr/bin/env bash
# DroidShell :: scripts/ds-sandbox.sh
# Manage plugin sandbox permissions (net / fs / exec / root).
# Usage: ds-sandbox.sh <plugin> <action>
#   Actions: allow-net  allow-fs  allow-exec  allow-root
#            revoke-net revoke-fs revoke-exec revoke-root
#            show       check <perm>

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; C='\033[1;36m'; N='\033[0m'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="${BASE_DIR}/plugins"

[[ -n "${1:-}" ]] || { echo "Usage: $(basename "$0") <plugin> <action>"; exit 1; }
PLUGIN="$1"
ACTION="${2:-show}"
PERM_FILE="${PLUGIN_DIR}/${PLUGIN}/permissions"

[[ -d "${PLUGIN_DIR}/${PLUGIN}" ]] || {
  echo -e "${R}[!] Plugin not found: ${PLUGIN}${N}"; exit 1; }

mkdir -p "$(dirname "$PERM_FILE")"
touch "$PERM_FILE"

_grant() {
  grep -qxF "$1" "$PERM_FILE" 2>/dev/null && {
    echo -e "${Y}[!] ${PLUGIN} already has ${1} permission${N}"; return; }
  echo "$1" >> "$PERM_FILE"
  echo -e "${G}[✓] Granted ${1} to ${PLUGIN}${N}"
}

_revoke() {
  grep -qxF "$1" "$PERM_FILE" 2>/dev/null || {
    echo -e "${Y}[!] ${PLUGIN} does not have ${1} permission${N}"; return; }
  sed -i "/^${1}$/d" "$PERM_FILE"
  echo -e "${G}[✓] Revoked ${1} from ${PLUGIN}${N}"
}

case "$ACTION" in
  allow-net)   _grant  "net"  ;;
  allow-fs)    _grant  "fs"   ;;
  allow-exec)  _grant  "exec" ;;
  allow-root)  _grant  "root" ;;
  revoke-net)  _revoke "net"  ;;
  revoke-fs)   _revoke "fs"   ;;
  revoke-exec) _revoke "exec" ;;
  revoke-root) _revoke "root" ;;
  show)
    echo -e "${C}Permissions for ${PLUGIN}:${N}"
    [[ -s "$PERM_FILE" ]] && cat "$PERM_FILE" || echo "  (none)"
    ;;
  check)
    PERM="${3:-}"
    [[ -n "$PERM" ]] || { echo "Usage: check <perm>"; exit 1; }
    if grep -qxF "$PERM" "$PERM_FILE" 2>/dev/null; then
      echo -e "${G}[✓] ${PLUGIN} has ${PERM}${N}"; exit 0
    else
      echo -e "${Y}[✗] ${PLUGIN} does NOT have ${PERM}${N}"; exit 1
    fi
    ;;
  *)
    echo "Unknown action: ${ACTION}"
    echo "Valid: allow-{net,fs,exec,root}  revoke-{net,fs,exec,root}  show  check <perm>"
    exit 1 ;;
esac
