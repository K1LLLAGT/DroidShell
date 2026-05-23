#!/usr/bin/env bash
set -euo pipefail
a="${1:-}"; b="${2:-}"
[ -z "$a" ] || [ -z "$b" ] && { echo "Usage: ds-lab-diff-env.sh <snapshot-a> <snapshot-b>"; exit 1; }
diff -u "$a" "$b" || { echo "[LAB] Differences"; exit 1; }
echo "[LAB] Identical"
