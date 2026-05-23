#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
for f in "$ROOT"/scripts/ds-*.sh; do
  echo "$(basename "$f")"
done
