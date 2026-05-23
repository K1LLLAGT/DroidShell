#!/usr/bin/env bash
# Refresh module dependency graphs

set -euo pipefail

ROOT="$HOME/DroidShell"

bash "$ROOT/scripts/ds-module-graph.sh"

DOT="$ROOT/registry/graphs/modules-graph.dot"
PNG="$ROOT/registry/graphs/modules-graph.png"

if command -v dot >/dev/null 2>&1; then
  dot -Tpng "$DOT" -o "$PNG"
  echo "[GRAPH] PNG generated: $PNG"
else
  echo "[GRAPH] Graphviz not installed; skipping PNG"
fi
