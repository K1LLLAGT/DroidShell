#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
cmd="${1:-}"
case "$cmd" in
  last) cd "$ROOT"
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          git reset --hard HEAD~1
        else
          echo "Not a git repo"; exit 1
        fi;;
  *) echo "Usage: $0 last";;
esac
