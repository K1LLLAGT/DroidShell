#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$BASE_DIR/VERSION"
OTA_DIR="$BASE_DIR/ota"
MAGISK_JSON="$OTA_DIR/magisk-update.json"

version="$(cat "$VERSION_FILE")"

cat > "$MAGISK_JSON" <<EOF
{
  "version": "$version",
  "versionCode": 1,
  "zipUrl": "https://github.com/K1LLLAGT/DroidShell/releases/download/v$version-stable/droidshell-magisk-$version.zip",
  "changelog": "https://github.com/K1LLLAGT/DroidShell/releases/tag/v$version-stable"
}
EOF

echo "[+] Updated Magisk update JSON"
