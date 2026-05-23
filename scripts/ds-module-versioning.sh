#!/usr/bin/env bash
# =============================================================================
#  ds-module-versioning.sh
#  Simple per-module version + changelog system.
#
#  Usage:
#    ds-module-versioning.sh bump <script> <major|minor|patch> [message]
#    ds-module-versioning.sh show <script>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
VER_DIR="$ROOT/registry/versions"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
log()  { echo -e "${G}[VER]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
err()  { echo -e "${R}[ERR]${N} $*"; exit 1; }

mkdir -p "$VER_DIR"

cmd="${1:-}"; shift || true

ver_file_for() {
  local script="$1"
  local base
  base="$(basename "$script")"
  echo "$VER_DIR/${base}.ver"
}

bump_version() {
  local old="$1" part="$2"
  local major minor patch
  IFS='.' read -r major minor patch <<< "${old:-0.0.0}"
  case "$part" in
    major) major=$((major+1)); minor=0; patch=0 ;;
    minor) minor=$((minor+1)); patch=0 ;;
    patch) patch=$((patch+1)) ;;
    *) err "Unknown part: $part" ;;
  esac
  echo "${major}.${minor}.${patch}"
}

case "$cmd" in
  bump)
    script="${1:-}"; part="${2:-}"; msg="${3:-no message}"
    [[ -z "$script" || -z "$part" ]] && err "Usage: bump <script> <major|minor|patch> [message]"
    vf="$(ver_file_for "$script")"
    old_ver="0.0.0"
    [[ -f "$vf" ]] && old_ver="$(head -1 "$vf" | awk '{print $2}' || echo "0.0.0")"
    new_ver="$(bump_version "$old_ver" "$part")"
    {
      echo "version $new_ver $(date)"
      echo "- $msg"
      echo ""
      [[ -f "$vf" ]] && tail -n +3 "$vf" || true
    } > "${vf}.tmp"
    mv "${vf}.tmp" "$vf"
    log "Bumped $(basename "$script") from $old_ver to $new_ver"
    ;;
  show)
    script="${1:-}"
    [[ -z "$script" ]] && err "Usage: show <script>"
    vf="$(ver_file_for "$script")"
    [[ -f "$vf" ]] || { warn "No version info for $script"; exit 0; }
    cat "$vf"
    ;;
  *)
    err "Usage: $0 {bump|show} ..."
    ;;
esac
