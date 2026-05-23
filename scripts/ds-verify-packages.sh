#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$BASE_DIR/out"
SIG_FILE="$OUT_DIR/OTA.SHA256"

cd "$OUT_DIR"
sha256sum -c "$SIG_FILE"
