#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
echo "[BOOTSTRAP] Running module registry..."
"$ROOT/scripts/ds-module-registry.sh" || true
echo "[BOOTSTRAP] Running module tree..."
"$ROOT/scripts/ds-module-tree.sh" || true
echo "[BOOTSTRAP] Done."
