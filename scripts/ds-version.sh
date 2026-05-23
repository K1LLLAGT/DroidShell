#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$BASE_DIR/VERSION"

cmd="${1:-show}"

read_version() {
  [ -f "$VERSION_FILE" ] && cat "$VERSION_FILE" || echo "0.0.0"
}

write_version() {
  echo "$1" > "$VERSION_FILE"
}

bump() {
  cur="$(read_version)"
  IFS='.' read -r MAJ MIN PAT <<< "$cur"
  case "$1" in
    major) MAJ=$((MAJ+1)); MIN=0; PAT=0 ;;
    minor) MIN=$((MIN+1)); PAT=0 ;;
    patch) PAT=$((PAT+1)) ;;
  esac
  echo "$MAJ.$MIN.$PAT"
}

case "$cmd" in
  show) read_version ;;
  major) write_version "$(bump major)" ;;
  minor) write_version "$(bump minor)" ;;
  patch) write_version "$(bump patch)" ;;
  *)
    echo "Usage: $0 {show|major|minor|patch}"
    exit 1
    ;;
esac
