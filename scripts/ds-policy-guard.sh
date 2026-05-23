#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
STATE_DIR="$ROOT/registry/state"
mkdir -p "$STATE_DIR"
cmd="${1:-}"; script="${2:-}"
[ "$cmd" != "check" ] && { echo "Usage: ds-policy-guard.sh check <script>"; exit 1; }
sf="$STATE_DIR/$(basename "$script").state"
[ -f "$sf" ] && [ "$(cat "$sf")" = "disabled" ] && { echo "[GUARD] disabled"; exit 1; }
echo "[GUARD] ok"
