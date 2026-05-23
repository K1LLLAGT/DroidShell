#!/usr/bin/env bash
set -euo pipefail

OLD_DIR="${1:-}"
NEW_DIR="${2:-}"
OUT_ARCHIVE="${3:-delta-root-modules.tar.gz}"

if [ -z "$OLD_DIR" ] || [ -z "$NEW_DIR" ]; then
  echo "Usage: $0 <old> <new> [out]"
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cd "$NEW_DIR/root/modules"

for f in *.sh; do
  [ -f "$f" ] || continue
  if [ ! -f "$OLD_DIR/root/modules/$f" ] || ! cmp -s "$f" "$OLD_DIR/root/modules/$f"; then
    cp "$f" "$TMP/$f"
  fi
done

cd "$TMP"
tar -czf "$OUT_ARCHIVE" .
echo "[+] Delta archive created: $OUT_ARCHIVE"
