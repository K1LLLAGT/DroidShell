#!/usr/bin/env bash
set -e

ROOT="/data/data/com.termux/files/home/DroidShell-Build"
REPO="$ROOT/source/DroidShell"

echo "[ds-build] Running initializer..."
$ROOT/droidshell-init.sh --no-clone

echo "[ds-build] Running sanity check..."
$ROOT/scripts/ds-check.sh

echo "[ds-build] Building APK..."
cd "$REPO"
./gradlew assembleDebug

OUT="$ROOT/release-out"
mkdir -p "$OUT"

APK=$(find "$REPO/app/build/outputs/apk/debug" -name "*.apk" | head -n 1)

if [ -z "$APK" ]; then
    echo "[ERROR] No APK produced."
    exit 1
fi

cp "$APK" "$OUT/DroidShell-latest.apk"

echo "[ds-build] Build complete."
echo "[ds-build] APK: $OUT/DroidShell-latest.apk"
