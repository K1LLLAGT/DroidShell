#!/usr/bin/env bash
# ds-qr-installer.sh
# Generates a QR code that installs the latest APK.

set -euo pipefail

REPO="K1LLLAGT/DroidShell"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

APK_URL=$(curl -s $API_URL | grep browser_download_url | grep .apk | cut -d '"' -f 4)

if [ -z "$APK_URL" ]; then
  echo "[!] No APK found."
  exit 1
fi

echo "[+] Generating QR code..."
echo "$APK_URL" | qrencode -o droidshell-latest.png

echo "[✓] QR code saved as droidshell-latest.png"
