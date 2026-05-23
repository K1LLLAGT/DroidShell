#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
OUT="$ROOT/registry/integrity.snapshot"
cd "$ROOT"
find . -type f ! -path "./.git/*" ! -path "./out/*" -print0 | sort -z | xargs -0 sha256sum > "$OUT"
echo "[INTEGRITY] Snapshot: $OUT"
