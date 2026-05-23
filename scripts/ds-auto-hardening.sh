#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
find "$ROOT/scripts" -type f -name "*.sh" -exec chmod 750 {} \;
chmod -R 700 "$ROOT/registry"
