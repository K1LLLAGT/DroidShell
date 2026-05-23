#!/data/data/com.termux/files/usr/bin/bash
# ds-sync.sh — sync engine

SYNC_DIR="sync"
mkdir -p "$SYNC_DIR"

case "$1" in
  push)
    cp -r "$2" "$SYNC_DIR"
    echo "[SYNC] Pushed $2"
    ;;
  pull)
    cp -r "$SYNC_DIR/$2" .
    echo "[SYNC] Pulled $2"
    ;;
  list)
    ls -1 "$SYNC_DIR"
    ;;
  *)
    echo "Usage: ds-sync.sh {push|pull|list} <path>"
    ;;
esac
