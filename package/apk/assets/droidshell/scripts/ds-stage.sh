#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
STAGE="$ROOT/build/stage"

echo "[STAGE] Cleaning stage directory"
rm -rf "$STAGE"
mkdir -p "$STAGE"

echo "[STAGE] Copying runtime tree into stage"
rsync -av \
  --exclude ".git" \
  --exclude "package" \
  --exclude "out" \
  --exclude "site" \
  --exclude "registry/graphs" \
  --exclude "tools/electron/node_modules" \
  --exclude "source/DroidShell/app/build" \
  "$ROOT/" "$STAGE/"

echo "[STAGE] Done. Staged runtime at: $STAGE"
