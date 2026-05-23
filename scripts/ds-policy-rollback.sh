#!/usr/bin/env bash
# =============================================================================
#  ds-policy-rollback.sh
#  Simple rollback helper using git (if repo is under git).
#
#  Usage:
#    ds-policy-rollback.sh last
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

cmd="${1:-}"

case "$cmd" in
  last)
    cd "$ROOT"
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      echo "[ROLLBACK] Resetting to HEAD~1"
      git reset --hard HEAD~1
    else
      echo "[ROLLBACK] Not a git repo"
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 last"
    ;;
esac
