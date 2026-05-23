#!/usr/bin/env bash
# =============================================================================
#  ds-dist-import.sh
#  Imports a DroidShell environment archive.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
ARCHIVE="${1:-}"

[[ -z "$ARCHIVE" ]] && { echo "[IMPORT] Usage: ds-dist-import.sh <archive>"; exit 1; }

echo "[IMPORT] Extracting $ARCHIVE → $ROOT"
tar -xzf "$ARCHIVE" -C "$ROOT"

echo "[IMPORT] Done."
