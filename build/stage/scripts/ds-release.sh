#!/usr/bin/env bash
# Create a release tarball of DroidShell.

set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/out"
mkdir -p "$OUT"

version="${1:-}"
if [ -z "$version" ]; then
  version="$(date +%Y%m%d-%H%M%S)"
fi

archive="$OUT/droidshell-release-$version.tar.gz"

echo "[RELEASE] Building docs and graphs..."
bash "$ROOT/scripts/ds-make.sh" all

echo "[RELEASE] Creating archive: $archive"
tar -czf "$archive" -C "$ROOT" \
  scripts \
  docs \
  registry/graphs \
  site \
  GIT-SUMMARY.* \
  README.*

echo "[RELEASE] Done: $archive"
