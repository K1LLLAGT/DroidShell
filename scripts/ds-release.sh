#!/usr/bin/env bash
set -e

OUT="release-out"
TS=$(date +%Y%m%d-%H%M%S)
NAME="DroidShell-release-$TS.zip"

mkdir -p "$OUT"
TMP="$OUT/tmp"
rm -rf "$TMP"
mkdir -p "$TMP"

echo "[DroidShell] Collecting release payload..."

copy_dir() {
    [ -d "$1" ] && cp -a "$1" "$TMP/" || echo "[REL] Missing: $1"
}

copy_dir "$HOME/.droidshell"
copy_dir "$HOME/.termux"
copy_dir docs
copy_dir site
copy_dir plugin-sdk
copy_dir plugin-template

# Include all orchestrator scripts
cp ds-* "$TMP/" 2>/dev/null || true

cd "$TMP"
zip -r "../$NAME" . >/dev/null
cd -

rm -rf "$TMP"

echo "[DroidShell] Release ZIP created: $OUT/$NAME"
