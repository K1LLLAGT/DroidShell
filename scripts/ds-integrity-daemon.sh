#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
INTERVAL="${1:-300}"
[ -f "$ROOT/registry/integrity.snapshot" ] || "$ROOT/scripts/ds-integrity-snapshot.sh"
while true; do
  "$ROOT/scripts/ds-integrity-compare.sh" || echo "[INTEGRITY] mismatch"
  sleep "$INTERVAL"
done
