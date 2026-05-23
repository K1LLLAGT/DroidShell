#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"

version="${1:-}"
if [ -z "$version" ]; then
  echo "Usage: ds-release-automation.sh <version>"
  exit 1
fi

bash "$ROOT/scripts/ds-release.sh" "$version"

echo "[REL-AUTO] Tagging v$version"
git tag "v$version"
git push origin "v$version"
