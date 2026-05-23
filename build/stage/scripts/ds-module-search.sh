#!/usr/bin/env bash
# ds-module-search.sh
set -euo pipefail
ROOT="$HOME/DroidShell"
term="${1:-}"
[ -z "$term" ] && { echo "Usage: ds-module-search.sh <term>"; exit 1; }
grep -Rni --color=always "$term" "$ROOT/scripts" || true
