#!/usr/bin/env bash
# ds-build-dual.sh - build root + non-root DroidShell packages (zip-based)

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$BASE_DIR/out"
ROOT_PKG="$OUT_DIR/droidshell-root.zip"
NONROOT_PKG="$OUT_DIR/droidshell-nonroot.zip"

mkdir -p "$OUT_DIR"

echo "[+] Building non-root package → $NONROOT_PKG"
cd "$BASE_DIR"
zip -r "$NONROOT_PKG" root scripts ds_root.sh \
  -x "root/*modules/*" \
  -x "root/*magisk*" \
  >/dev/null

echo "[+] Building root package → $ROOT_PKG"
cd "$BASE_DIR"
zip -r "$ROOT_PKG" root scripts ds_root.sh magisk-droidshell \
  >/dev/null

echo "[✓] Built:"
echo "  $NONROOT_PKG"
echo "  $ROOT_PKG"
