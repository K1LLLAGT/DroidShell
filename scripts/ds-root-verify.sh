#!/usr/bin/env bash
set -euo pipefail

MOD_DIR="${1:-root/modules}"
SIG_FILE="${2:-root/modules.SHA256}"

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "[!] sha256sum not available."
  exit 1
fi

if [ ! -f "$SIG_FILE" ]; then
  echo "[!] Signature file not found: $SIG_FILE"
  exit 1
fi

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

cp "$SIG_FILE" "$TMP"
pushd "$MOD_DIR" >/dev/null 2>&1
sha256sum -c "$TMP"
popd >/dev/null 2>&1
