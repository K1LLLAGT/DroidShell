#!/usr/bin/env bash
# DroidShell UX Suite Generator
# Generates:
#   scripts/ds-docs-serve.sh
#   scripts/ds-graph-tui.sh
#   scripts/ds-man.sh
#   scripts/ds-docs-search.sh
#   scripts/ds-dashboard.sh
#   scripts/ds-release.sh

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
mkdir -p "$SCRIPTS"

echo "[UX] Writing ds-docs-serve.sh"
cat > "$SCRIPTS/ds-docs-serve.sh" << 'EOF_SERVE'
#!/usr/bin/env bash
# Serve site/ over HTTP and optionally auto-rebuild docs.

set -euo pipefail

ROOT="$HOME/DroidShell"
SITE="$ROOT/site"
PORT="${1:-8000}"
WATCH="${2:-}"

if [ ! -d "$SITE" ]; then
  echo "[SERVE] site/ not found, building..."
  bash "$ROOT/scripts/ds-make.sh" docs
fi

if [ "$WATCH" = "watch" ]; then
  echo "[SERVE] Watch mode: rebuilding docs every 10 seconds"
  (
    while true; do
      bash "$ROOT/scripts/ds-make.sh" docs >/dev/null 2>&1 || true
      sleep 10
    done
  ) &
fi

cd "$SITE"
echo "[SERVE] Serving on http://127.0.0.1:$PORT"
if command -v python >/dev/null 2>&1; then
  python -m http.server "$PORT"
elif command -v python3 >/dev/null 2>&1; then
  python3 -m http.server "$PORT"
else
  echo "No python http.server available."
  exit 1
fi
EOF_SERVE
chmod +x "$SCRIPTS/ds-docs-serve.sh"

echo "[UX] Writing ds-graph-tui.sh"
cat > "$SCRIPTS/ds-graph-tui.sh" << 'EOF_GTUI'
#!/usr/bin/env bash
# Simple TUI to view module graph ASCII and DOT info.

set -euo pipefail

ROOT="$HOME/DroidShell"
GRAPH_DIR="$ROOT/registry/graphs"
ASCII="$GRAPH_DIR/modules-graph.txt"
DOT="$GRAPH_DIR/modules-graph.dot"

if [ ! -f "$ASCII" ] || [ ! -f "$DOT" ]; then
  echo "[GRAPH-TUI] Graph not found, regenerating..."
  bash "$ROOT/scripts/ds-graphs-refresh.sh"
fi

while true; do
  clear
  echo "DroidShell Module Graph TUI"
  echo "1) View ASCII graph"
  echo "2) View DOT file"
  echo "3) Regenerate graph"
  echo "4) Quit"
  echo
  printf "Choice: "
  read -r choice
  case "$choice" in
    1)
      clear
      echo "ASCII Graph:"
      echo "------------"
      cat "$ASCII"
      echo
      read -r -p "Press Enter to return..." _
      ;;
    2)
      clear
      echo "DOT Graph:"
      echo "----------"
      cat "$DOT"
      echo
      read -r -p "Press Enter to return..." _
      ;;
    3)
      bash "$ROOT/scripts/ds-graphs-refresh.sh"
      read -r -p "Regenerated. Press Enter..." _
      ;;
    4)
      exit 0
      ;;
    *)
      ;;
  esac
done
EOF_GTUI
chmod +x "$SCRIPTS/ds-graph-tui.sh"

echo "[UX] Writing ds-man.sh"
cat > "$SCRIPTS/ds-man.sh" << 'EOF_MANVIEW'
#!/usr/bin/env bash
# View generated manpage for a ds-* module.

set -euo pipefail

ROOT="$HOME/DroidShell"
MAN_DIR="$ROOT/docs/man"

name="${1:-}"
if [ -z "$name" ]; then
  echo "Usage: ds-man.sh <ds-module-name or ds-module-name.sh>"
  exit 1
fi

case "$name" in
  *.sh) base="${name%.sh}" ;;
  *) base="$name" ;;
esac

file="$MAN_DIR/$base.1.txt"

if [ ! -f "$file" ]; then
  echo "[MAN] Manpage not found, regenerating..."
  bash "$ROOT/scripts/ds-manpages-generate.sh"
fi

if [ ! -f "$file" ]; then
  echo "[MAN] Still not found: $file"
  exit 1
fi

${PAGER:-less} "$file"
EOF_MANVIEW
chmod +x "$SCRIPTS/ds-man.sh"

echo "[UX] Writing ds-docs-search.sh"
cat > "$SCRIPTS/ds-docs-search.sh" << 'EOF_DSEARCH'
#!/usr/bin/env bash
# Search across docs/ for a term.

set -euo pipefail

ROOT="$HOME/DroidShell"
DOCS="$ROOT/docs"

term="${1:-}"
if [ -z "$term" ]; then
  echo "Usage: ds-docs-search.sh <term>"
  exit 1
fi

grep -Rni --color=always "$term" "$DOCS" || echo "[SEARCH] No matches."
EOF_DSEARCH
chmod +x "$SCRIPTS/ds-docs-search.sh"

echo "[UX] Writing ds-dashboard.sh"
cat > "$SCRIPTS/ds-dashboard.sh" << 'EOF_DASH'
#!/usr/bin/env bash
# Simple dashboard TUI for DroidShell.

set -euo pipefail

ROOT="$HOME/DroidShell"

count_modules() {
  ls "$ROOT"/scripts/ds-*.sh 2>/dev/null | wc -l
}

count_docs() {
  find "$ROOT/docs" -maxdepth 2 -type f -name "*.md" 2>/dev/null | wc -l
}

while true; do
  clear
  echo "DroidShell Dashboard"
  echo "--------------------"
  echo "Modules:      $(count_modules)"
  echo "Docs files:   $(count_docs)"
  echo
  echo "1) Build docs (ds-make.sh docs)"
  echo "2) Refresh graphs (ds-make.sh graphs)"
  echo "3) Build all (ds-make.sh all)"
  echo "4) View module graph TUI"
  echo "5) Search docs"
  echo "6) Quit"
  echo
  printf "Choice: "
  read -r choice
  case "$choice" in
    1) bash "$ROOT/scripts/ds-make.sh" docs; read -r -p "Done. Enter..." _ ;;
    2) bash "$ROOT/scripts/ds-make.sh" graphs; read -r -p "Done. Enter..." _ ;;
    3) bash "$ROOT/scripts/ds-make.sh" all; read -r -p "Done. Enter..." _ ;;
    4) bash "$ROOT/scripts/ds-graph-tui.sh" ;;
    5)
       printf "Search term: "
       read -r term
       bash "$ROOT/scripts/ds-docs-search.sh" "$term"
       read -r -p "Done. Enter..." _
       ;;
    6) exit 0 ;;
    *) ;;
  esac
done
EOF_DASH
chmod +x "$SCRIPTS/ds-dashboard.sh"

echo "[UX] Writing ds-release.sh"
cat > "$SCRIPTS/ds-release.sh" << 'EOF_REL'
#!/usr/bin/env bash
# Create a release tarball of DroidShell.

set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/out"
mkdir -p "$OUT"

version="${1:-}"
if [ -z "$version" ]; then
  version="$(date +%Y%m%d-%H%M%S)"
fi

archive="$OUT/droidshell-release-$version.tar.gz"

echo "[RELEASE] Building docs and graphs..."
bash "$ROOT/scripts/ds-make.sh" all

echo "[RELEASE] Creating archive: $archive"
tar -czf "$archive" -C "$ROOT" \
  scripts \
  docs \
  registry/graphs \
  site \
  GIT-SUMMARY.* \
  README.*

echo "[RELEASE] Done: $archive"
EOF_REL
chmod +x "$SCRIPTS/ds-release.sh"

echo "[UX] UX suite generation complete."
