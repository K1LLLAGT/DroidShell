#!/usr/bin/env bash
set -e

REPO_NAME="DroidShell"

if [ ! -d "$REPO_NAME" ]; then
  echo "[DroidShell] Repo '$REPO_NAME' not found. Run droidshell-init.sh first."
  exit 1
fi

cd "$REPO_NAME"

echo "[DroidShell] Running Gradle build (debug)..."
./gradlew assembleDebug

APK_PATH="app/build/outputs/apk/debug/app-debug.apk"

if [ ! -f "$APK_PATH" ]; then
  echo "[DroidShell] APK not found at $APK_PATH"
  exit 1
fi

OUT_DIR="../droidshell-out"
mkdir -p "$OUT_DIR"
cp "$APK_PATH" "$OUT_DIR/droidshell-debug.apk"

echo "[DroidShell] Build complete."
echo "APK: $OUT_DIR/droidshell-debug.apk"
