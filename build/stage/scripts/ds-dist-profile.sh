#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
STATE="$ROOT/registry/state"
PROFILES="$ROOT/registry/profiles"
mkdir -p "$STATE" "$PROFILES"
cmd="${1:-}"; name="${2:-}"
case "$cmd" in
  save) [ -z "$name" ] && { echo "Usage: save <name>"; exit 1; }
        cp -r "$STATE" "$PROFILES/$name";;
  load) [ -z "$name" ] && { echo "Usage: load <name>"; exit 1; }
        cp -r "$PROFILES/$name" "$STATE";;
  list) ls "$PROFILES";;
  *) echo "Usage: $0 {save|load|list}";;
esac
