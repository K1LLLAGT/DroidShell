#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
SNAPS="$ROOT/registry"
count="${1:-5}"
ls -t "$SNAPS"/integrity.snapshot* 2>/dev/null | tail -n +$((count+1)) | xargs -r rm -f
