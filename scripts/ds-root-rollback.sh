#!/usr/bin/env bash
set -euo pipefail

ROOT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SNAP_DIR="$ROOT_BASE_DIR/root/snapshots"

SNAP="${1:-}"

if [ -z "$SNAP" ]; then
  echo "Available snapshots:"
  ls -1 "$SNAP_DIR"/snapshot-*.tar.gz 2>/dev/null || echo "  (none)"
  echo
  echo "Usage: $0 <snapshot-file>"
  exit 0
fi

if [ ! -f "$SNAP" ]; then
  echo "[!] Snapshot not found: $SNAP"
  exit 1
fi

tar -xzf "$SNAP" -C "$ROOT_BASE_DIR"
echo "[+] Restored from snapshot: $SNAP"
