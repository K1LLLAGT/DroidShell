#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
[ -d "$ROOT/scripts" ] || { echo "[INV] missing scripts/"; exit 1; }
echo "[INV] OK"
