#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
OUT="$ROOT/out"
count="${1:-5}"
ls -t "$OUT"/droidshell-export-* 2>/dev/null | tail -n +$((count+1)) | xargs -r rm -f
