#!/usr/bin/env bash
set -euo pipefail

REPO="K1LLLAGT/DroidShell"
BRANCH="${1:-main}"
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[+] Fetching latest modules from $REPO@$BRANCH..."
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -L "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" -o "$TMP/src.tar.gz"
tar -xzf "$TMP/src.tar.gz" -C "$TMP"

SUBDIR=$(find "$TMP" -maxdepth 1 -type d -name "DroidShell-*")
if [ -z "$SUBDIR" ]; then
  echo "[!] Could not locate extracted repo."
  exit 1
fi

if [ -d "$SUBDIR/root/modules" ]; then
  cp "$SUBDIR/root/modules/"*.sh "$TARGET_DIR"/
  echo "[+] Modules updated in $TARGET_DIR"
else
  echo "[!] No root/modules directory in archive."
fi
