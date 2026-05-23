#!/data/data/com.termux/files/usr/bin/bash
# ds-sandbox.sh — execution sandbox

SANDBOX_DIR="sandbox"
mkdir -p "$SANDBOX_DIR"

case "$1" in
  run)
    echo "[SANDBOX] Running in isolated mode: $2"
    bash -c "$2"
    ;;
  clean)
    rm -rf "$SANDBOX_DIR"/*
    echo "[SANDBOX] Cleaned."
    ;;
  *)
    echo "Usage: ds-sandbox.sh {run|clean} <command>"
    ;;
esac
