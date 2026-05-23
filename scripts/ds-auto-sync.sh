#!/usr/bin/env bash
# =============================================================================
#  ds-auto-sync.sh
#  Simple sync helper (e.g., to a remote backup via git or rsync).
#
#  Usage:
#    ds-auto-sync.sh [remote]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
REMOTE="${1:-origin}"

cd "$ROOT"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[AUTO-SYNC] Committing and pushing to $REMOTE"
  git add -A
  git commit -m "Auto-sync $(date +%Y-%m-%dT%H:%M:%S)" || echo "[AUTO-SYNC] Nothing to commit"
  git push "$REMOTE" HEAD || echo "[AUTO-SYNC] Push failed"
else
  echo "[AUTO-SYNC] Not a git repo"
  exit 1
fi
