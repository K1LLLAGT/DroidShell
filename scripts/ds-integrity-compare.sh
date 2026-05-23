#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
SNAP="$ROOT/registry/integrity.snapshot"
[ -f "$SNAP" ] || { echo "No snapshot"; exit 1; }
cd "$ROOT"
TMP=$(mktemp)
find . -type f ! -path "./.git/*" ! -path "./out/*" -print0 | sort -z | xargs -0 sha256sum > "$TMP"
diff -u "$SNAP" "$TMP" || { echo "Differences detected"; rm -f "$TMP"; exit 1; }
rm -f "$TMP"
echo "No differences."
