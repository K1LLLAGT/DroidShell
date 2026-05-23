#!/usr/bin/env bash
# =============================================================================
#  ds-integrity-compare.sh
#  Compares current tree against saved snapshot.
#
#  Usage:
#    ds-integrity-compare.sh
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SNAP="$ROOT/registry/integrity.snapshot"

[[ -f "$SNAP" ]] || { echo "[INTEGRITY] No snapshot found"; exit 1; }

cd "$ROOT"

echo "[INTEGRITY] Comparing against snapshot…"

TMP=$(mktemp)
find . -type f \
  ! -path "./.git/*" \
  ! -path "./out/*" \
  -print0 | sort -z | xargs -0 sha256sum > "$TMP"

diff -u "$SNAP" "$TMP" || {
  echo "[INTEGRITY] Differences detected."
  rm -f "$TMP"
  exit 1
}

rm -f "$TMP"
echo "[INTEGRITY] No differences."
