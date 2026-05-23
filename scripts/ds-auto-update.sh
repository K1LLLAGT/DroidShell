#!/usr/bin/env bash
# =============================================================================
#  ds-auto-update.sh
#  Pulls latest changes from git and runs bootstrap.
#
#  Usage:
#    ds-auto-update.sh
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

cd "$ROOT"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[AUTO-UPDATE] Fetching latest…"
  git pull --rebase
else
  echo "[AUTO-UPDATE] Not a git repo"
  exit 1
fi

if [[ -x "$ROOT/scripts/ds-bootstrap-all.sh" ]]; then
  echo "[AUTO-UPDATE] Running bootstrap…"
  "$ROOT/scripts/ds-bootstrap-all.sh"
fi

echo "[AUTO-UPDATE] Done."
