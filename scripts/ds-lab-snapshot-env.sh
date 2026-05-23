#!/usr/bin/env bash
# =============================================================================
#  ds-lab-snapshot-env.sh
#  Captures an environment snapshot for lab/experiment reproducibility.
#
#  Output:
#    registry/lab-env-<name>.snapshot
#
#  Usage:
#    ds-lab-snapshot-env.sh <name>
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
REG="$ROOT/registry"

name="${1:-}"
[[ -z "$name" ]] && { echo "Usage: ds-lab-snapshot-env.sh <name>"; exit 1; }

OUT="$REG/lab-env-${name}.snapshot"

{
  echo "# DroidShell Lab Environment Snapshot: $name"
  echo "# Date: $(date)"
  echo ""
  echo "## uname -a"
  uname -a
  echo ""
  echo "## env"
  env | sort
  echo ""
  echo "## scripts checksum"
  (cd "$ROOT" && find scripts -type f -name "ds-*.sh" -print0 | sort -z | xargs -0 sha256sum)
} > "$OUT"

echo "[LAB] Environment snapshot written: $OUT"
