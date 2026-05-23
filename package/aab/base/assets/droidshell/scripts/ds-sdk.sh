#!/usr/bin/env bash
set -e

OUT="sdk-out"
TS=$(date +%Y%m%d)
NAME="DroidShell-SDK-$TS.zip"

mkdir -p "$OUT"
TMP="$OUT/tmp"
rm -rf "$TMP"
mkdir -p "$TMP"

echo "[DroidShell] Building SDK bundle..."

copy_if_exists() {
    [ -d "$1" ] && cp -a "$1" "$TMP/" || echo "[SDK] Missing: $1"
}

copy_if_exists plugin-sdk
copy_if_exists plugin-template
copy_if_exists docs
copy_if_exists site

cat > "$TMP/README.md" << 'EOREAD'
# DroidShell SDK Bundle

Includes:
- plugin-sdk/
- plugin-template/
- docs/
- site/
EOREAD

cd "$TMP"
zip -r "../$NAME" . >/dev/null
cd -

rm -rf "$TMP"

echo "[DroidShell] SDK bundle created: $OUT/$NAME"
