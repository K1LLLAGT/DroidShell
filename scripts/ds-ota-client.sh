#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OTA_DIR="$BASE_DIR/ota"
OUT_DIR="$BASE_DIR/out"
META_FILE="$OTA_DIR/metadata.json"

log() { echo "[DroidShell-OTA-Client] $*"; }

if [ ! -f "$META_FILE" ]; then
  log "No metadata.json found at $META_FILE"
  exit 1
fi

channel="${1:-stable}"

jq_bin="$(command -v jq || true)"
if [ -z "$jq_bin" ]; then
  log "jq is required. Install: pkg install jq"
  exit 1
fi

root_url="$(jq -r ".channels.$channel.root" "$META_FILE")"
nonroot_url="$(jq -r ".channels.$channel.nonroot" "$META_FILE")"

if [ -z "$root_url" ] && [ -z "$nonroot_url" ]; then
  log "No URLs configured for channel '$channel'"
  exit 1
fi

is_root() {
  if command -v su >/dev/null 2>&1 && su -c "id -u" 2>/dev/null | grep -q '^0$'; then
    return 0
  fi
  return 1
}

mkdir -p "$OUT_DIR"

if is_root && [ -n "$root_url" ]; then
  log "Root detected, using root package: $root_url"
  pkg_path="$OUT_DIR/droidshell-root-update.zip"
  curl -L "$root_url" -o "$pkg_path"
  log "Downloaded: $pkg_path"
  log "Flash this via recovery/Magisk or your preferred method."
elif [ -n "$nonroot_url" ]; then
  log "No root or root package unavailable, using non-root package: $nonroot_url"
  pkg_path="$OUT_DIR/droidshell-nonroot-update.zip"
  curl -L "$nonroot_url" -o "$pkg_path"
  log "Downloaded: $pkg_path"
  log "Install/update according to your non-root distribution method."
else
  log "No suitable package found for this device/channel."
  exit 1
fi
