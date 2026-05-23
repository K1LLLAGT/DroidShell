#!/usr/bin/env bash
# ds-update-checker.sh
# Checks GitHub Releases for a newer version.

set -euo pipefail

REPO="K1LLLAGT/DroidShell"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

LATEST=$(curl -s $API_URL | grep tag_name | cut -d '"' -f 4)
CURRENT=$(grep versionName source/DroidShell/app/build.gradle | cut -d '"' -f 2)

if [ "$LATEST" != "$CURRENT" ]; then
  echo "update_available=true" > ~/.droidshell-update
else
  echo "update_available=false" > ~/.droidshell-update
fi
