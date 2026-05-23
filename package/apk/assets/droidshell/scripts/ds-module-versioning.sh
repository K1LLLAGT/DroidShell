#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
REG="$ROOT/registry/versions"
mkdir -p "$REG"
echo "1.0.0" > "$REG/version.txt"
echo "[VERSION] 1.0.0"
