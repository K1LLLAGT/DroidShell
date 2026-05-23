#!/usr/bin/env bash
set -euo pipefail

REPO="K1LLLAGT/DroidShell"
BRANCH="${1:-main}"

curl -sSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/ds-install-universal.sh" -o ds-install-universal.sh
chmod +x ds-install-universal.sh

echo "[+] Downloaded ds-install-universal.sh"
echo "[i] Review it, then run:"
echo "    ./ds-install-universal.sh"
