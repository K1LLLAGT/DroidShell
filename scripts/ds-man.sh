#!/usr/bin/env bash
# DroidShell Manpage Viewer
# Usage:
#   ds-man.sh <command>
#   ds-man.sh list

set -e

ROOT="/sdcard/DroidShell"
MAN="$ROOT/docs/man"

usage() {
    echo "Usage:"
    echo "  ds-man.sh <command>"
    echo "  ds-man.sh list"
    exit 1
}

# Ensure man directory exists
mkdir -p "$MAN"

# List all manpages
if [ "$1" = "list" ]; then
    echo "Available DroidShell manpages:"
    for f in $(ls "$MAN"/*.md 2>/dev/null | sort); do
        base=$(basename "$f")
        cmd="${base%.1.md}"
        echo "  - $cmd"
    done
    exit 0
fi

# Require argument
[ -z "$1" ] && usage

QUERY="$1"

# Exact match first
if [ -f "$MAN/$QUERY.1.md" ]; then
    FILE="$MAN/$QUERY.1.md"
else
    # Fuzzy match
    FILE=$(ls "$MAN"/*"$QUERY"*.md 2>/dev/null | head -n 1 || true)
fi

if [ ! -f "$FILE" ]; then
    echo "[ds-man] No manpage found for '$QUERY'"
    exit 1
fi

# Display manpage
if command -v less >/dev/null 2>&1; then
    less "$FILE"
else
    cat "$FILE"
fi
