#!/usr/bin/env bash
set -e

ROOT="$HOME/DroidShell-Build"
REPO="$ROOT/pkg-repo"
INDEX="$REPO/index.txt"

cmd="$1"
arg="$2"

init_repo() {
  mkdir -p "$REPO"
  touch "$INDEX"
  echo "[DroidShell] Repo initialized at $REPO"
}

add_pkg() {
  FILE="$arg"
  [ -z "$FILE" ] && echo "Usage: ds-pkg-repo.sh add <pkg.ds>" && exit 1
  [ ! -f "$FILE" ] && echo "Package not found: $FILE" && exit 1

  mkdir -p "$REPO"
  NAME=$(basename "$FILE")
  cp "$FILE" "$REPO/$NAME"
  echo "$NAME $(date)" >> "$INDEX"
  echo "[DroidShell] Added package: $NAME"
}

serve_repo() {
  PORT="${arg:-8080}"
  cd "$REPO"
  echo "[DroidShell] Serving repo on http://0.0.0.0:$PORT/"
  python -m http.server "$PORT"
}

case "$cmd" in
  init)   init_repo ;;
  add)    add_pkg ;;
  serve)  serve_repo ;;
  *)
    echo "Usage: ds-pkg-repo.sh {init|add <pkg.ds>|serve [port]}"
    exit 1
    ;;
esac
