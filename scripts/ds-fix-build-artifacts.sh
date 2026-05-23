#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
cd "$ROOT"

GITIGNORE="$ROOT/.gitignore"

ensure_pattern() {
  local pat="$1"
  grep -qxF "$pat" "$GITIGNORE" 2>/dev/null || echo "$pat" >> "$GITIGNORE"
}

touch "$GITIGNORE"

echo "[FIX] Ensuring build artifacts are ignored"
ensure_pattern "# Build artifacts"
ensure_pattern "build/"
ensure_pattern "out/"
ensure_pattern "package/"
ensure_pattern "*.apk"
ensure_pattern "*.aab"
ensure_pattern "*.deb"

echo "[FIX] Removing build artifacts from index (not from disk)"
git rm -r --cached build/ out/ package/ 2>/dev/null || true

echo "[FIX] Done. Now run:"
echo "  git add .gitignore"
echo "  git commit -m \"Ignore build artifacts and remove binaries from index\""
echo "  git push"
