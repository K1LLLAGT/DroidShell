#!/data/data/com.termux/files/usr/bin/bash
# ds-profiler.sh — runtime profiler

PROFILE_LOG="profiler.log"

start() {
  echo "[PROFILER] Start: $(date)" >> "$PROFILE_LOG"
}

stop() {
  echo "[PROFILER] Stop: $(date)" >> "$PROFILE_LOG"
}

case "$1" in
  start) start ;;
  stop) stop ;;
  log) cat "$PROFILE_LOG" ;;
  *)
    echo "Usage: ds-profiler.sh {start|stop|log}"
    ;;
esac
