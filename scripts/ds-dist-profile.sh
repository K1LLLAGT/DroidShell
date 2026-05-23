#!/usr/bin/env bash
# =============================================================================
#  ds-dist-profile.sh
#  Saves and loads DroidShell profiles (sets of enabled modules).
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
STATE="$ROOT/registry/state"
PROFILES="$ROOT/registry/profiles"

mkdir -p "$PROFILES"

cmd="${1:-}"

case "$cmd" in
  save)
    name="${2:-}"
    [[ -z "$name" ]] && { echo "Usage: save <name>"; exit 1; }
    cp -r "$STATE" "$PROFILES/$name"
    echo "[PROFILE] Saved profile: $name"
    ;;
  load)
    name="${2:-}"
    [[ -z "$name" ]] && { echo "Usage: load <name>"; exit 1; }
    cp -r "$PROFILES/$name" "$STATE"
    echo "[PROFILE] Loaded profile: $name"
    ;;
  list)
    ls "$PROFILES"
    ;;
  *)
    echo "Usage: $0 {save|load|list}"
    ;;
esac
