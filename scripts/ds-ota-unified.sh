#!/usr/bin/env bash
# ds-ota-unified.sh
# Unified OTA updater for root + non-root DroidShell packages.

set -euo pipefail

REPO="K1LLLAGT/DroidShell"
BRANCH="${1:-main}"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$BASE_DIR/out"
mkdir -p "$OUT_DIR"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

log() { echo "[DroidShell-OTA] $*"; }

log "Fetching latest from $REPO@$BRANCH..."
curl -L "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" -o "$TMP/src.tar.gz"

tar -xzf "$TMP/src.tar.gz" -C "$TMP"
SUBDIR="$(find "$TMP" -maxdepth 1 -type d -name "DroidShell-*")"

if [ -z "$SUBDIR" ]; then
  log "Could not locate extracted repo."
  exit 1
fi

log "Rebuilding dual packages from latest source..."
cd "$SUBDIR"
if [ -x "scripts/ds-dual-system.sh" ]; then
  ./scripts/ds-dual-system.sh
fi
if [ -x "scripts/ds-build-dual.sh" ]; then
  ./scripts/ds-build-dual.sh
fi

if [ -d "$SUBDIR/out" ]; then
  cp "$SUBDIR/out/"droidshell-*.zip "$OUT_DIR"/
  log "Updated packages copied to: $OUT_DIR"
else
  log "No out/ directory found in latest build."
fi
