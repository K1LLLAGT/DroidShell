#!/usr/bin/env bash
set -euo pipefail

ROOT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOD_DIR="$ROOT_BASE_DIR/root/modules"
STATE_FILE="$ROOT_BASE_DIR/root/modules.state"

mkdir -p "$MOD_DIR"
touch "$STATE_FILE"

list_modules() {
  echo "Modules:"
  i=1
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    enabled="on"
    if grep -q "^$name:off$" "$STATE_FILE"; then
      enabled="off"
    fi
    printf "  %2d) %-20s [%s]\n" "$i" "$name" "$enabled"
    i=$((i+1))
  done < <(ls "$MOD_DIR"/*.sh 2>/dev/null)
}

toggle_module() {
  name="$1"
  grep -v "^$name:" "$STATE_FILE" > "$STATE_FILE.tmp" || true
  mv "$STATE_FILE.tmp" "$STATE_FILE"
  if grep -q "^$name:off$" "$STATE_FILE" 2>/dev/null; then
    sed -i "s/^$name:off$/$name:on/" "$STATE_FILE"
  else
    echo "$name:off" >> "$STATE_FILE"
  fi
}

while true; do
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " Root Module Manager"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  list_modules
  echo
  echo "Enter module name to toggle, or 'q' to quit:"
  read -r ans
  case "$ans" in
    q|Q) exit 0 ;;
    *)
      if [ -f "$MOD_DIR/$ans" ]; then
        toggle_module "$ans"
      else
        echo "No such module: $ans"
        sleep 1
      fi
      ;;
  esac
done
