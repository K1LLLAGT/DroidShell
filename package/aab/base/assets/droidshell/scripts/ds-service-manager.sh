#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$BASE_DIR/scripts"
PID_DIR="$BASE_DIR/run"

mkdir -p "$PID_DIR"

log() { echo "[DroidShell-SVC] $*"; }

cmd="${1:-help}"

case "$cmd" in
  start-updater)
    if [ -f "$PID_DIR/updater.pid" ] && kill -0 "$(cat "$PID_DIR/updater.pid")" 2>/dev/null; then
      log "Updater already running."
      exit 0
    fi
    nohup "$SCRIPTS/ds-updater-daemon.sh" 60 >/dev/null 2>&1 &
    echo $! > "$PID_DIR/updater.pid"
    log "Updater started with PID $(cat "$PID_DIR/updater.pid")"
    ;;
  stop-updater)
    if [ -f "$PID_DIR/updater.pid" ]; then
      kill "$(cat "$PID_DIR/updater.pid")" 2>/dev/null || true
      rm -f "$PID_DIR/updater.pid"
      log "Updater stopped."
    else
      log "No updater PID file."
    fi
    ;;
  status)
    if [ -f "$PID_DIR/updater.pid" ] && kill -0 "$(cat "$PID_DIR/updater.pid")" 2>/dev/null; then
      log "Updater running (PID $(cat "$PID_DIR/updater.pid"))."
    else
      log "Updater not running."
    fi
    ;;
  help|*)
    echo "DroidShell Service Manager"
    echo "Usage:"
    echo "  $0 start-updater"
    echo "  $0 stop-updater"
    echo "  $0 status"
    ;;
esac
