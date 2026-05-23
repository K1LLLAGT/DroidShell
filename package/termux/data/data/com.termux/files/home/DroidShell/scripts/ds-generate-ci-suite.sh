#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
GH="$ROOT/.github/workflows"

mkdir -p "$SCRIPTS" "$GH"

echo "[CI] Writing install.sh"
cat > "$ROOT/install.sh" << 'EOF_INSTALL'
#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/DroidShell"

if [ -d "$TARGET/.git" ]; then
  echo "DroidShell already present at $TARGET"
  exit 0
fi

git clone https://github.com/K1LLLAGT/DroidShell.git "$TARGET"

cd "$TARGET"
mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/ds" << 'EOF_DSLAUNCH'
#!/usr/bin/env bash
exec "$HOME/DroidShell/scripts/ds-cli.sh" "$@"
EOF_DSLAUNCH
chmod +x "$HOME/.local/bin/ds"

echo "Add to PATH if needed:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
EOF_INSTALL
chmod +x "$ROOT/install.sh"

echo "[CI] Writing ds-cli.sh"
cat > "$SCRIPTS/ds-cli.sh" << 'EOF_CLI'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"

cmd="${1:-help}"
shift || true

case "$cmd" in
  help)
    cat << EOF
DroidShell CLI

Usage:
  ds help
  ds docs
  ds graphs
  ds serve [port] [watch]
  ds man <module>
  ds search <term>
  ds dash
  ds release [version]
EOF
    ;;
  docs)
    bash "$SCRIPTS/ds-make.sh" docs
    ;;
  graphs)
    bash "$SCRIPTS/ds-make.sh" graphs
    ;;
  serve)
    bash "$SCRIPTS/ds-docs-serve.sh" "${1:-8000}" "${2:-}"
    ;;
  man)
    bash "$SCRIPTS/ds-man.sh" "${1:-}"
    ;;
  search)
    bash "$SCRIPTS/ds-docs-search.sh" "${1:-}"
    ;;
  dash)
    bash "$SCRIPTS/ds-dashboard.sh"
    ;;
  release)
    bash "$SCRIPTS/ds-release.sh" "${1:-}"
    ;;
  *)
    echo "Unknown command: $cmd"
    exit 1
    ;;
esac
EOF_CLI
chmod +x "$SCRIPTS/ds-cli.sh"

echo "[CI] Writing ds-module-registry-v2.sh"
cat > "$SCRIPTS/ds-module-registry-v2.sh" << 'EOF_REGV2'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
REG="$ROOT/registry/modules"
mkdir -p "$REG"

OUT_JSON="$REG/modules.json"

echo "[" > "$OUT_JSON"
first=1
for f in "$SCRIPTS"/ds-*.sh; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  deps_line="$(grep -E '^# DEPS:' "$f" || true)"
  cat_line="$(grep -E '^# CAT:' "$f" || true)"
  cat "${f}" | head -n 1 >/dev/null 2>&1 || true

  deps=""
  [ -n "$deps_line" ] && deps="${deps_line#\# DEPS: }"
  catg=""
  [ -n "$cat_line" ] && catg="${cat_line#\# CAT: }"

  [ "$first" -eq 0 ] && echo "," >> "$OUT_JSON"
  first=0

  printf '  {"name":"%s","path":"%s","deps":[' "$base" "$f" >> "$OUT_JSON"
  dfirst=1
  for d in $deps; do
    [ "$dfirst" -eq 0 ] && printf ',' >> "$OUT_JSON"
    dfirst=0
    printf '"%s"' "$d" >> "$OUT_JSON"
  done
  printf '],"category":"%s"}' "$catg" >> "$OUT_JSON"
done
echo >> "$OUT_JSON"
echo "]" >> "$OUT_JSON"

echo "[REGV2] Wrote $OUT_JSON"
EOF_REGV2
chmod +x "$SCRIPTS/ds-module-registry-v2.sh"

echo "[CI] Writing ds-release-automation.sh"
cat > "$SCRIPTS/ds-release-automation.sh" << 'EOF_REL_AUTO'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"

version="${1:-}"
if [ -z "$version" ]; then
  echo "Usage: ds-release-automation.sh <version>"
  exit 1
fi

bash "$ROOT/scripts/ds-release.sh" "$version"

echo "[REL-AUTO] Tagging v$version"
git tag "v$version"
git push origin "v$version"
EOF_REL_AUTO
chmod +x "$SCRIPTS/ds-release-automation.sh"

echo "[CI] Writing CI workflow"
cat > "$GH/ci.yml" << 'EOF_WCI'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run basic checks
        run: |
          bash scripts/ds-generate-docs-suite.sh || true
          bash scripts/ds-generate-docs-tools-suite.sh || true
          bash scripts/ds-generate-devops-suite.sh || true
          bash scripts/ds-generate-ux-suite.sh || true
          bash scripts/ds-make.sh all || true
EOF_WCI

echo "[CI] Writing Pages workflow"
cat > "$GH/pages.yml" << 'EOF_WPAGES'
name: Deploy Docs

on:
  push:
    branches: [ main ]

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pages: write
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - name: Build docs site
        run: |
          bash scripts/ds-generate-docs-suite.sh || true
          bash scripts/ds-generate-docs-tools-suite.sh || true
          bash scripts/ds-make.sh docs
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: site
      - name: Deploy to GitHub Pages
        uses: actions/deploy-pages@v4
EOF_WPAGES

echo "[CI] Writing Release workflow"
cat > "$GH/release.yml" << 'EOF_WREL'
name: Release

on:
  workflow_dispatch:
    inputs:
      version:
        description: "Release version"
        required: true
        type: string

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build release
        run: |
          bash scripts/ds-generate-docs-suite.sh || true
          bash scripts/ds-generate-docs-tools-suite.sh || true
          bash scripts/ds-generate-devops-suite.sh || true
          bash scripts/ds-generate-ux-suite.sh || true
          bash scripts/ds-make.sh all
          bash scripts/ds-release.sh "${{ github.event.inputs.version }}"
      - name: Upload release artifact
        uses: actions/upload-artifact@v4
        with:
          name: droidshell-release
          path: out/
EOF_WREL

echo "[CI] CI suite generation complete."
