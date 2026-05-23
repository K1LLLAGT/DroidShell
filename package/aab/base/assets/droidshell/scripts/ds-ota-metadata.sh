#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
META_FILE="$BASE_DIR/ota/metadata.json"
VERSION_FILE="$BASE_DIR/VERSION"
OUT_DIR="$BASE_DIR/out"

version="$(cat "$VERSION_FILE")"

root_pkg="$OUT_DIR/droidshell-root.zip"
nonroot_pkg="$OUT_DIR/droidshell-nonroot.zip"

root_sig=""
nonroot_sig=""

if command -v sha256sum >/dev/null 2>&1; then
  [ -f "$root_pkg" ] && root_sig="$(sha256sum "$root_pkg" | awk '{print $1}')"
  [ -f "$nonroot_pkg" ] && nonroot_sig="$(sha256sum "$nonroot_pkg" | awk '{print $1}')"
fi

cat > "$META_FILE" <<EOF
{
  "version": "$version",
  "channels": {
    "stable": {
      "root": "out/droidshell-root.zip",
      "nonroot": "out/droidshell-nonroot.zip"
    },
    "beta": { "root": "", "nonroot": "" },
    "dev": { "root": "", "nonroot": "" }
  },
  "signatures": {
    "root": "$root_sig",
    "nonroot": "$nonroot_sig"
  }
}
EOF

echo "[+] Updated OTA metadata"
