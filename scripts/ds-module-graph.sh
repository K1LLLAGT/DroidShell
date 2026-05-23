#!/usr/bin/env bash
# ds-module-graph.sh
# Produce a simple module dependency graph:
# - ASCII adjacency list
# - Optional Graphviz .dot file

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
OUT_DIR="$ROOT/registry/graphs"
mkdir -p "$OUT_DIR"

ASCII_OUT="$OUT_DIR/modules-graph.txt"
DOT_OUT="$OUT_DIR/modules-graph.dot"

# Convention: dependencies are declared in scripts as:
#   # DEPS: ds-foo.sh ds-bar.sh
#
# This script parses those lines.

echo "# DroidShell Module Dependency Graph" > "$ASCII_OUT"

echo "digraph droidshell_modules {" > "$DOT_OUT"
echo "  rankdir=LR;" >> "$DOT_OUT"
echo "  node [shape=box, fontname=\"Helvetica\"];" >> "$DOT_OUT"

for f in "$SCRIPTS"/ds-*.sh; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  deps_line="$(grep -E '^# DEPS:' "$f" || true)"
  if [ -z "$deps_line" ]; then
    echo "$base: (no explicit deps)" >> "$ASCII_OUT"
    echo "  \"$base\";" >> "$DOT_OUT"
    continue
  fi
  deps="${deps_line#\# DEPS: }"
  echo "$base: $deps" >> "$ASCII_OUT"
  for d in $deps; do
    echo "  \"$base\" -> \"$d\";" >> "$DOT_OUT"
  done
done

echo "}" >> "$DOT_OUT"

echo "[GRAPH] ASCII: $ASCII_OUT"
echo "[GRAPH] DOT:   $DOT_OUT"
echo "[GRAPH] If you have Graphviz, run: dot -Tpng \"$DOT_OUT\" -o \"$OUT_DIR/modules-graph.png\""
