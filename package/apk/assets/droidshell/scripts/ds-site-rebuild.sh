#!/usr/bin/env bash
# Rebuild static HTML site from docs/

set -euo pipefail

ROOT="$HOME/DroidShell"

bash "$ROOT/scripts/ds-docs-site.sh"
echo "[SITE] Rebuild complete."
