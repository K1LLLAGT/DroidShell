#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$BASE_DIR/out"
SIG_FILE="$OUT_DIR/OTA.SHA256"

> "$SIG_FILE"

cd "$OUT_DIR"
for f in droidshell-*.zip; do
  [ -f "$f" ] || continue
  sha256sum "$f" >> "$SIG_FILE"
done

echo "[+] Wrote signatures to $SIG_FILE"
