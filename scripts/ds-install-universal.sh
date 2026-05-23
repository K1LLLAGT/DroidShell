#!/usr/bin/env bash
# ds-install-universal.sh
# Auto-detect root stack + install root or non-root package.

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$BASE_DIR/out"
ROOT_ZIP="$OUT_DIR/droidshell-root.zip"
NONROOT_ZIP="$OUT_DIR/droidshell-nonroot.zip"

log() { echo "[DroidShell-Install] $*"; }

detect_root_stack() {
  if command -v su >/dev/null 2>&1; then
    if su -c "magisk -v" >/dev/null 2>&1; then
      echo "Magisk"
      return 0
    fi
    if su -v 2>/dev/null | grep -qi "supersu"; then
      echo "SuperSU"
      return 0
    fi
    if su -c "uname -a" 2>/dev/null | grep -qi "kernelsu"; then
      echo "KernelSU"
      return 0
    fi
    echo "GenericSU"
    return 0
  fi
  echo "NoRoot"
}

is_root_working() {
  if ! command -v su >/dev/null 2>&1; then
    return 1
  fi
  if ! su -c "id" >/dev/null 2>&1; then
    return 1
  fi
  UID="$(su -c "id -u" 2>/dev/null || echo 1)"
  [ "$UID" = "0" ]
}

STACK="$(detect_root_stack)"
log "Detected root stack: $STACK"

if is_root_working; then
  log "Root is functional."
  if [ ! -f "$ROOT_ZIP" ]; then
    log "Root package not found: $ROOT_ZIP"
    exit 1
  fi
  log "Root install path depends on environment:"
  log "  • For Magisk: flash $ROOT_ZIP in Magisk Manager."
  log "  • For others: unpack and deploy manually (non-automated for safety)."
else
  log "No functional root. Using non-root package."
  if [ ! -f "$NONROOT_ZIP" ]; then
    log "Non-root package not found: $NONROOT_ZIP"
    exit 1
  fi
  log "Non-root package ready at: $NONROOT_ZIP"
  log "Install method depends on how DroidShell is distributed (APK, zip, etc.)."
fi
