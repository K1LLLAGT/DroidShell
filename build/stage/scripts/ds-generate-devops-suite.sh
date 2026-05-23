#!/usr/bin/env bash
# DroidShell DevOps Suite Generator
# Generates:
#   .gitignore (DroidShell tuned)
#   scripts/ds-docs-index.sh
#   scripts/ds-site-rebuild.sh
#   scripts/ds-graphs-refresh.sh
#   scripts/ds-make.sh

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"

mkdir -p "$SCRIPTS"

echo "[DEVOPS] Writing .gitignore"
cat > "$ROOT/.gitignore" << 'EOF_GIT'
# DroidShell GitIgnore

# Generated site output
site/

# Graphviz outputs
registry/graphs/*.png
registry/graphs/*.svg

# Logs
registry/*.log
registry/*/*.log

# Snapshots
registry/*.snapshot
registry/*/*.snapshot

# Backups
out/*.tar.gz

# Temp files
*.tmp
*.swp
EOF_GIT

echo "[DEVOPS] Writing ds-docs-index.sh"
cat > "$SCRIPTS/ds-docs-index.sh" << 'EOF_INDEX'
#!/usr/bin/env bash
# Build docs/index-table.md listing all docs/*.md

set -euo pipefail

ROOT="$HOME/DroidShell"
DOCS="$ROOT/docs"
OUT="$DOCS/index-table.md"

echo "# Documentation Index" > "$OUT"
echo >> "$OUT"

for f in "$DOCS"/*.md; do
  base="$(basename "$f")"
  echo "- $base" >> "$OUT"
done

echo "[INDEX] Wrote $OUT"
EOF_INDEX
chmod +x "$SCRIPTS/ds-docs-index.sh"

echo "[DEVOPS] Writing ds-site-rebuild.sh"
cat > "$SCRIPTS/ds-site-rebuild.sh" << 'EOF_SITE'
#!/usr/bin/env bash
# Rebuild static HTML site from docs/

set -euo pipefail

ROOT="$HOME/DroidShell"

bash "$ROOT/scripts/ds-docs-site.sh"
echo "[SITE] Rebuild complete."
EOF_SITE
chmod +x "$SCRIPTS/ds-site-rebuild.sh"

echo "[DEVOPS] Writing ds-graphs-refresh.sh"
cat > "$SCRIPTS/ds-graphs-refresh.sh" << 'EOF_GRAPH'
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
EOF_GRAPH
chmod +x "$SCRIPTS/ds-graphs-refresh.sh"

echo "[DEVOPS] Writing ds-make.sh"
cat > "$SCRIPTS/ds-make.sh" << 'EOF_MAKE'
#!/usr/bin/env bash
# Make-style wrapper for common tasks

set -euo pipefail

ROOT="$HOME/DroidShell"

case "$1" in
  docs)
    bash "$ROOT/scripts/ds-docs-index.sh"
    bash "$ROOT/scripts/ds-docs-site.sh"
    echo "[MAKE] Docs built."
    ;;
  graphs)
    bash "$ROOT/scripts/ds-graphs-refresh.sh"
    echo "[MAKE] Graphs refreshed."
    ;;
  all)
    bash "$ROOT/scripts/ds-docs-index.sh"
    bash "$ROOT/scripts/ds-docs-site.sh"
    bash "$ROOT/scripts/ds-graphs-refresh.sh"
    echo "[MAKE] All tasks complete."
    ;;
  *)
    echo "Usage: ds-make.sh {docs|graphs|all}"
    exit 1
    ;;
esac
EOF_MAKE
chmod +x "$SCRIPTS/ds-make.sh"

echo "[DEVOPS] DevOps suite generation complete."
