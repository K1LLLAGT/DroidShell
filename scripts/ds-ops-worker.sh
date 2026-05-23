#!/usr/bin/env bash
# =============================================================================
#  ds-ops-worker.sh
#  Processes jobs from the queue FIFO-style.
#
#  Usage:
#    ds-ops-worker.sh
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
QUEUE="$ROOT/registry/queue"

while true; do
  job=$(ls "$QUEUE"/*.job 2>/dev/null | head -1 || true)
  [[ -z "$job" ]] && { sleep 1; continue; }

  echo "[WORKER] Processing: $(basename "$job")"
  read -r script args < "$job"
  bash "$ROOT/scripts/$script" $args || echo "[WORKER] Job failed"
  rm -f "$job"
done
