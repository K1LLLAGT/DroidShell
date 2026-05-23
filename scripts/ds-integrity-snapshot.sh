#!/usr/bin/env bash
# =============================================================================
#  ds-integrity-snapshot.sh
#  Takes a snapshot of file checksums for later comparison.
#
#  Output:
#    registry/integrity.snapshot
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/registry/integrity.snapshot"

echo "[INTEGRITY] Creating snapshot at: $OUT"

cd "$ROOT"
find . -type f \
  ! -path "./.git/*" \
  ! -path "./out/*" \
  -print0 | sort -z | xargs -0 sha256sum > "$OUT"

echo "[INTEGRITY] Snapshot complete."
