#!/usr/bin/env bash
set -euo pipefail

ROOT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOD_DIR="$ROOT_BASE_DIR/root/modules"
STATE_FILE="$ROOT_BASE_DIR/root/modules.state"
SNAP_DIR="$ROOT_BASE_DIR/root/snapshots"

mkdir -p "$SNAP_DIR"

STAMP=$(date +"%Y%m%d-%H%M%S")
ARCHIVE="$SNAP_DIR/snapshot-$STAMP.tar.gz"

tar -czf "$ARCHIVE" -C "$ROOT_BASE_DIR" root/modules root/modules.state 2>/dev/null || \
tar -czf "$ARCHIVE" -C "$ROOT_BASE_DIR" root/modules 2>/dev/null

echo "[+] Snapshot created: $ARCHIVE"
