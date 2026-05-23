#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REG_DIR="$BASE_DIR/registry"
INDEX="$REG_DIR/index.json"

NAME="${1:-}"
FILE="${2:-}"

if [ -z "$NAME" ] || [ -z "$FILE" ]; then
  echo "Usage: $0 <name> <file>"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "[!] File not found: $FILE"
  exit 1
fi

mkdir -p "$REG_DIR/packages"
pkg="$(basename "$FILE")"
cp "$FILE" "$REG_DIR/packages/$pkg"

tmp="$INDEX.tmp"
jq ".packages += [{\"name\":\"$NAME\",\"file\":\"packages/$pkg\"}]" "$INDEX" > "$tmp"
mv "$tmp" "$INDEX"

echo "[+] Added package '$NAME'"
