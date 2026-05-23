#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
"$ROOT/scripts/ds-module-registry.sh" || true
"$ROOT/scripts/ds-module-tree.sh" || true
"$ROOT/scripts/ds-module-docs.sh" || true
"$ROOT/scripts/ds-module-search.sh" "ds-" || true
