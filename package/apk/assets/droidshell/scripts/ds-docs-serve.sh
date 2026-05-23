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
