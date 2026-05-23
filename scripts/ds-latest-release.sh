#!/usr/bin/env bash
# ds-latest-release.sh
# Downloads and installs the latest DroidShell release APK

set -euo pipefail

REPO="K1LLLAGT/DroidShell"

echo "[+] Fetching latest release info..."
API_URL="https://api.github.com/repos/$REPO/releases/latest"
APK_URL=$(curl -s $API_URL | grep browser_download_url | grep .apk | cut -d '"' -f 4)

if [ -z "$APK_URL" ]; then
  echo "[!] No APK found in latest release."
  exit 1
fi

echo "[+] Downloading APK:"
echo "    $APK_URL"
curl -L "$APK_URL" -o droidshell-latest.apk

echo "[+] Installing APK..."
pm install -r droidshell-latest.apk

echo "[✓] DroidShell updated to latest release."
