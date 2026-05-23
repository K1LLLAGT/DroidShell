#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
QUEUE="$ROOT/registry/queue"
while true; do
  job=$(ls "$QUEUE"/*.job 2>/dev/null | head -1 || true)
  [ -z "$job" ] && { sleep 1; continue; }
  read -r script args < "$job"
  bash "$ROOT/scripts/$script" $args || echo "[WORKER] Job failed"
  rm -f "$job"
done
