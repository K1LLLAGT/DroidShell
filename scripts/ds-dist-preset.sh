#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
STATE="$ROOT/registry/state"
mkdir -p "$STATE"
preset="${1:-}"
case "$preset" in
  minimal) find "$STATE" -type f -delete;;
  full)    for f in "$ROOT"/scripts/ds-*.sh; do
             echo "enabled" > "$STATE/$(basename "$f").state"
           done;;
  *) echo "Usage: $0 {minimal|full}";;
esac
