#!/usr/bin/env bash
# =============================================================================
#  ds-dist-export.sh
#  Exports a full DroidShell environment into a portable archive.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/out/droidshell-export-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "[EXPORT] Creating archive: $OUT"
tar -czf "$OUT" \
  --exclude="out/*.tar.gz" \
  --exclude="registry/versions/*.tmp" \
  -C "$ROOT" .

echo "[EXPORT] Done."
