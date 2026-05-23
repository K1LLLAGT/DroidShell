#!/usr/bin/env bash
# =============================================================================
#  ds-dist-preset.sh
#  Applies predefined DroidShell presets (minimal, full, dev, root).
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
STATE="$ROOT/registry/state"

mkdir -p "$STATE"

preset="${1:-}"

case "$preset" in
  minimal)
    echo "[PRESET] Applying minimal preset"
    find "$STATE" -type f -delete
    ;;
  full)
    echo "[PRESET] Enabling all modules"
    find "$ROOT/scripts" -maxdepth 1 -type f -name "ds-*.sh" | while read -r f; do
      echo "enabled" > "$STATE/$(basename "$f").state"
    done
    ;;
  dev)
    echo "[PRESET] Developer preset"
    echo "enabled" > "$STATE/ds-dev-tui.sh.state"
    echo "enabled" > "$STATE/ds-dev-launcher.sh.state"
    ;;
  root)
    echo "[PRESET] Root preset"
    find "$ROOT/scripts" -maxdepth 1 -type f -name "ds-root-*.sh" | while read -r f; do
      echo "enabled" > "$STATE/$(basename "$f").state"
    done
    ;;
  *)
    echo "Usage: $0 {minimal|full|dev|root}"
    ;;
esac
