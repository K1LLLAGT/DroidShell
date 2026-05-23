#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REG_DIR="$BASE_DIR/registry"
INDEX="$REG_DIR/index.json"
PKG_DIR="$REG_DIR/packages"

jq_bin="$(command -v jq || true)"
if [ -z "$jq_bin" ]; then
  echo "[DroidShell-PKG] jq is required. Install: pkg install jq"
  exit 1
fi

cmd="${1:-help}"
arg="${2:-}"

case "$cmd" in
  list)
    jq -r '.packages[] | "- \(.name) -> \(.file)"' "$INDEX"
    ;;
  info)
    if [ -z "$arg" ]; then
      echo "Usage: $0 info <name>"
      exit 1
    fi
    jq -r ".packages[] | select(.name==\"$arg\")" "$INDEX"
    ;;
  install)
    if [ -z "$arg" ]; then
      echo "Usage: $0 install <name>"
      exit 1
    fi
    file="$(jq -r ".packages[] | select(.name==\"$arg\") | .file" "$INDEX")"
    if [ -z "$file" ] || [ "$file" = "null" ]; then
      echo "[DroidShell-PKG] Package not found: $arg"
      exit 1
    fi
    full="$PKG_DIR/$(basename "$file")"
    if [ ! -f "$full" ]; then
      echo "[DroidShell-PKG] File missing: $full"
      exit 1
    fi
    echo "[DroidShell-PKG] Installing $arg from $full"
    # For now, just echo; you can define install semantics per package type.
    ;;
  help|*)
    echo "DroidShell Package Manager"
    echo "Usage:"
    echo "  $0 list"
    echo "  $0 info <name>"
    echo "  $0 install <name>"
    ;;
esac
