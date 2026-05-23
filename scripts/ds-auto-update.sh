#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
cd "$ROOT"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git pull --rebase
fi
[ -x "$ROOT/scripts/ds-bootstrap-all.sh" ] && "$ROOT/scripts/ds-bootstrap-all.sh"
