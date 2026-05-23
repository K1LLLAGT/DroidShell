#!/usr/bin/env bash
# Search across docs/ for a term.

set -euo pipefail

ROOT="$HOME/DroidShell"
DOCS="$ROOT/docs"

term="${1:-}"
if [ -z "$term" ]; then
  echo "Usage: ds-docs-search.sh <term>"
  exit 1
fi

grep -Rni --color=always "$term" "$DOCS" || echo "[SEARCH] No matches."
