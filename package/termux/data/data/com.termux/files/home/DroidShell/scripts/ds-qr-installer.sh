#!/usr/bin/env bash
# ds-qr-installer.sh
# Generate a QR code for a universal install command.

set -euo pipefail

if ! command -v qrencode >/dev/null 2>&1; then
  echo "[!] qrencode not installed. Install: pkg install qrencode"
  exit 1
fi

# This URL should point to a hosted copy of ds-install-universal.sh
INSTALL_URL="${1:-https://github.com/K1LLLAGT/DroidShell/raw/main/scripts/ds-install-universal.sh}"

CMD="curl -sSL \"$INSTALL_URL\" -o ds-install-universal.sh && chmod +x ds-install-universal.sh && ./ds-install-universal.sh"

echo "[+] Command encoded in QR:"
echo "    $CMD"
echo
qrencode -t ANSIUTF8 "$CMD"
