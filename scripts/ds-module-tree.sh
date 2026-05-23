#!/usr/bin/env bash
# =============================================================================
#  ds-module-tree.sh
#  Prints a hierarchical tree of modules and key bundles.
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"

G='\033[1;32m'; N='\033[0m'
log() { echo -e "${G}[TREE]${N} $*"; }

cd "$ROOT"

log "DroidShell Module Tree"
echo ""

echo "scripts/"
find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | sed 's|.*/|  ├── |'

echo ""
echo "bundles:"
for b in ds-bundle-ecosystem.sh ds-bundle-services.sh ds-bundle-runtime.sh; do
  if [[ -f "$SCRIPTS/$b" ]]; then
    echo "  - $b"
  fi
done

echo ""
echo "orchestrators:"
for o in ds-bootstrap-all.sh ds-fix-everything.sh ds-release-master.sh; do
  if [[ -f "$SCRIPTS/$o" ]]; then
    echo "  - $o"
  fi
done
