#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAGISK_DIR="$BASE_DIR/magisk-droidshell"
OUT_DIR="$BASE_DIR/out"
mkdir -p "$OUT_DIR"

VERSION_FILE="$MAGISK_DIR/module.prop"
VERSION="1.0.0"

if [ -f "$VERSION_FILE" ]; then
  VERSION=$(grep '^version=' "$VERSION_FILE" | cut -d'=' -f2- || echo "1.0.0")
fi

ZIP_NAME="droidshell-magisk-$VERSION.zip"
ZIP_PATH="$OUT_DIR/$ZIP_NAME"

echo "[+] Building Magisk module ZIP: $ZIP_PATH"

cd "$MAGISK_DIR"
# Standard Magisk module zip layout: contents of magisk-droidshell at root of zip
zip -r "$ZIP_PATH" . >/dev/null

echo "[✓] Built: $ZIP_PATH"
