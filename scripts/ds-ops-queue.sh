#!/usr/bin/env bash
# =============================================================================
#  ds-ops-queue.sh
#  Adds jobs to the DroidShell job queue.
#
#  Usage:
#    ds-ops-queue.sh add <script> [args...]
#    ds-ops-queue.sh list
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
QUEUE="$ROOT/registry/queue"

cmd="${1:-}"; shift || true

case "$cmd" in
  add)
    job_id="$(date +%s)-$RANDOM"
    echo "$@" > "$QUEUE/$job_id.job"
    echo "[QUEUE] Added job: $job_id"
    ;;
  list)
    ls "$QUEUE"
    ;;
  *)
    echo "Usage: $0 {add|list}"
    ;;
esac
