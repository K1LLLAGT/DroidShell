#!/usr/bin/env bash
# DroidShell :: root/fileops.sh
# Safe root-mode r/w for all protected system paths.
# Usage: fileops.sh <read|write|ls|find|stat|cp|cat> <args...>

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; C='\033[1;36m'; N='\033[0m'

# All system paths that require root access
ROOT_PATHS=(
  /cache /config /d /mnt /sys /oem /debug_ramdisk
  /system /vendor /data /proc /dev /etc /usr
)

# Guard: caller must have root
_require_root() {
  su -c "id" 2>/dev/null | grep -q "uid=0" || {
    echo -e "${R}[ERR] Root access required${N}" >&2; exit 1; }
}

# Validate that the path is under a known root-accessible tree
_validate_path() {
  local p="$1"
  for rp in "${ROOT_PATHS[@]}"; do
    [[ "$p" == "$rp"* ]] && return 0
  done
  echo -e "${Y}[WARN] Path '${p}' not in known root tree. Proceeding with caution.${N}"
}

_safe_read()  { _require_root; _validate_path "$1"; su -c "cat -- '$1'"; }
_safe_cat()   { _safe_read "$@"; }
_safe_ls()    { _require_root; _validate_path "$1"; su -c "ls -la -- '$1'"; }
_safe_stat()  { _require_root; _validate_path "$1"; su -c "stat -- '$1'"; }
_safe_find()  { _require_root; _validate_path "$1"; shift; su -c "find '$1' $*"; }

_safe_write() {
  _require_root
  local dst="$1"; shift
  _validate_path "$dst"
  # Write via temp then move to avoid partial writes on /system etc.
  local tmp; tmp="$(su -c 'mktemp /data/local/tmp/ds_write.XXXXXX')"
  cat "$@" | su -c "cat > '$tmp'"
  su -c "mv -f '$tmp' '$dst'"
  echo -e "${G}[✓] Wrote to ${dst}${N}"
}

_safe_cp() {
  _require_root
  local src="$1" dst="$2"
  _validate_path "$src"
  _validate_path "$dst"
  su -c "cp -a -- '$src' '$dst'"
  echo -e "${G}[✓] Copied ${src} → ${dst}${N}"
}

CMD="${1:-help}"; shift 2>/dev/null || true
case "$CMD" in
  read|cat)  _safe_cat  "$@" ;;
  ls)        _safe_ls   "$@" ;;
  stat)      _safe_stat "$@" ;;
  find)      _safe_find "$@" ;;
  write)     _safe_write "$@" ;;
  cp)        _safe_cp   "$@" ;;
  paths)     printf '%s\n' "${ROOT_PATHS[@]}" ;;
  help|*)
    echo "Usage: fileops.sh <cmd> <args>"
    echo "  read|cat  <path>            — print file contents"
    echo "  ls        <path>            — list directory"
    echo "  stat      <path>            — stat file/dir"
    echo "  find      <path> [opts...]  — find under path"
    echo "  write     <dst> [src|-]     — write file as root"
    echo "  cp        <src> <dst>       — copy as root"
    echo "  paths                       — list all root-accessible trees"
    ;;
esac
