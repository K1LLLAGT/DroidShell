#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
ARCHIVE="${1:-}"
[ -z "$ARCHIVE" ] && { echo "Usage: ds-dist-import.sh <archive>"; exit 1; }
tar -xzf "$ARCHIVE" -C "$ROOT"
echo "[IMPORT] $ARCHIVE"
