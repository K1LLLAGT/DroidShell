#!/usr/bin/env bash
# =============================================================================
#  ds-auto-hardening.sh
#  Applies basic hardening to the DroidShell tree.
#
#  - Tightens permissions on scripts and registry
#  - Ensures no world-writable files
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

echo "[HARDEN] Tightening script permissions…"
find "$ROOT/scripts" -type f -name "*.sh" -exec chmod 750 {} \;

echo "[HARDEN] Tightening registry permissions…"
chmod -R 700 "$ROOT/registry"

echo "[HARDEN] Checking for world-writable files…"
WW=$(find "$ROOT" -perm -0002 -type f || true)
if [[ -n "$WW" ]]; then
  echo "[HARDEN] WARNING: world-writable files detected:"
  echo "$WW"
else
  echo "[HARDEN] No world-writable files."
fi

echo "[HARDEN] Done."
