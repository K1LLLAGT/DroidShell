#!/usr/bin/env bash
set -e

ROOT="$HOME/DroidShell-Build"
SRC="$ROOT/source"
SCRIPTS="$ROOT/scripts"

echo "[DroidShell] Developer bootstrap starting..."
mkdir -p "$ROOT" "$SRC" "$SCRIPTS"

# Basic deps (Termux)
if command -v pkg >/dev/null 2>&1; then
  pkg install -y git openjdk-17 gradle zip || true
fi

# Ensure source exists
if [ ! -d "$SRC/DroidShell" ]; then
  echo "[DroidShell] Cloning + patching source via droidshell-init.sh"
  ( cd "$ROOT" && "$SCRIPTS/droidshell-init.sh" )
fi

# Build + sign APK
echo "[DroidShell] Running build + sign pipeline"
( cd "$ROOT" && "$SCRIPTS/droidshell-build-release.sh" )

# Docs + site
echo "[DroidShell] Initializing docs + site"
( cd "$ROOT" && "$SCRIPTS/droidshell-docs-init.sh" )
( cd "$ROOT" && "$SCRIPTS/droidshell-site-build.sh" )

# SDK + release ZIP
echo "[DroidShell] Building SDK + release ZIP"
( cd "$ROOT" && "$SCRIPTS/droidshell-sdk-build.sh" )
( cd "$ROOT" && "$SCRIPTS/droidshell-release-zip.sh" )

echo "[DroidShell] Dev bootstrap complete."
echo "[DroidShell] Root: $ROOT"
