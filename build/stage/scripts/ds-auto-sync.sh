#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
REMOTE="${1:-origin}"
cd "$ROOT"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add -A
  git commit -m "Auto-sync $(date +%Y-%m-%dT%H:%M:%S)" || true
  git push "$REMOTE" HEAD || true
fi
