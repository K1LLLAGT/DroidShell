#!/usr/bin/env bash
# View generated manpage for a ds-* module.

set -euo pipefail

ROOT="$HOME/DroidShell"
MAN_DIR="$ROOT/docs/man"

name="${1:-}"
if [ -z "$name" ]; then
  echo "Usage: ds-man.sh <ds-module-name or ds-module-name.sh>"
  exit 1
fi

case "$name" in
  *.sh) base="${name%.sh}" ;;
  *) base="$name" ;;
esac

file="$MAN_DIR/$base.1.txt"

if [ ! -f "$file" ]; then
  echo "[MAN] Manpage not found, regenerating..."
  bash "$ROOT/scripts/ds-manpages-generate.sh"
fi

if [ ! -f "$file" ]; then
  echo "[MAN] Still not found: $file"
  exit 1
fi

${PAGER:-less} "$file"
