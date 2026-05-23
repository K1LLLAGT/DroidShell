#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOCKS="$ROOT/registry/locks"
name="${1:-}"
[ -z "$name" ] && { echo "Usage: ds-ops-lock.sh <name>"; exit 1; }
lock="$LOCKS/$name.lock"
[ -f "$lock" ] && { echo "Locked"; exit 1; }
echo $$ > "$lock"
