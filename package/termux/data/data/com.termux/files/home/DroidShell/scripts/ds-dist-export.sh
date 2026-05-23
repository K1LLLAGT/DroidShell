#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
OUT="$ROOT/out/droidshell-export-$(date +%Y%m%d-%H%M%S).tar.gz"
mkdir -p "$ROOT/out"
tar -czf "$OUT" -C "$ROOT" .
echo "[EXPORT] $OUT"
