#!/usr/bin/env bash
# DroidShell :: scripts/ds-plugin-loader.sh
# Scans plugins/ for manifest.json + plugin.sh and runs each in order.
# Usage: ds-plugin-loader.sh [--dry-run] [--plugin <name>]

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; C='\033[1;36m'; N='\033[0m'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="${BASE_DIR}/plugins"
DRY_RUN=false
FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --plugin)  FILTER="$2"; shift ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
  shift
done

mkdir -p "$PLUGIN_DIR"
loaded=0; skipped=0; failed=0

for plugin_dir in "${PLUGIN_DIR}"/*/; do
  [[ -d "$plugin_dir" ]] || continue
  name="$(basename "$plugin_dir")"

  [[ -n "$FILTER" && "$name" != "$FILTER" ]] && continue

  manifest="${plugin_dir}/manifest.json"
  entry="${plugin_dir}/plugin.sh"
  perms="${plugin_dir}/permissions"

  if [[ ! -f "$manifest" ]]; then
    echo -e "${Y}[SKIP]${N} ${name}: missing manifest.json"
    ((skipped++)); continue
  fi
  if [[ ! -x "$entry" ]]; then
    echo -e "${Y}[SKIP]${N} ${name}: plugin.sh missing or not executable"
    ((skipped++)); continue
  fi

  echo -e "${C}[LOAD]${N} ${name}"
  [[ -f "$perms" ]] && echo -e "  perms: $(tr '\n' ',' < "$perms" | sed 's/,$//')"

  if $DRY_RUN; then
    echo -e "  ${Y}[DRY]${N} would exec: ${entry}"
    ((loaded++)); continue
  fi

  if bash "$entry"; then
    echo -e "  ${G}[OK]${N} ${name}"
    ((loaded++))
  else
    echo -e "  ${R}[FAIL]${N} ${name} exited non-zero"
    ((failed++))
  fi
done

echo -e "\n${C}Plugin summary: ${loaded} loaded, ${skipped} skipped, ${failed} failed${N}"
[[ $failed -eq 0 ]]
