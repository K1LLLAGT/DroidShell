#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
LOCKS="$ROOT/registry/locks"
name="${1:-}"
[ -z "$name" ] && { echo "Usage: ds-ops-unlock.sh <name>"; exit 1; }
rm -f "$LOCKS/$name.lock"
