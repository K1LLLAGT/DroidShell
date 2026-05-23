#!/usr/bin/env bash
set -euo pipefail

MOD_DIR="${1:-root/modules}"
OUT="${2:-root/modules.SHA256}"

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "[!] sha256sum not available."
  exit 1
fi

> "$OUT"
for f in "$MOD_DIR"/*.sh; do
  [ -f "$f" ] || continue
  sha256sum "$f" >> "$OUT"
done

echo "[+] Wrote signatures to $OUT"
