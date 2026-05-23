#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
REG="$ROOT/registry"
name="${1:-}"
[ -z "$name" ] && { echo "Usage: ds-lab-snapshot-env.sh <name>"; exit 1; }
OUT="$REG/lab-env-${name}.snapshot"
{
  echo "# Lab snapshot: $name"
  echo "# Date: $(date)"
  echo "## env"
  env | sort
} > "$OUT"
echo "[LAB] $OUT"
