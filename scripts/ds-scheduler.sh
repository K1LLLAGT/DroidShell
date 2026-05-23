#!/data/data/com.termux/files/usr/bin/bash
# ds-scheduler.sh — DroidShell task scheduler

SCHED_DIR="scheduler"
mkdir -p "$SCHED_DIR"

case "$1" in
  add)
    echo "$2" >> "$SCHED_DIR/tasks.list"
    echo "[SCHED] Added task: $2"
    ;;
  run)
    echo "[SCHED] Running scheduled tasks..."
    while IFS= read -r task; do
      echo "[SCHED] Executing: $task"
      bash -c "$task"
    done < "$SCHED_DIR/tasks.list"
    ;;
  list)
    echo "[SCHED] Scheduled tasks:"
    cat "$SCHED_DIR/tasks.list"
    ;;
  *)
    echo "Usage: ds-scheduler.sh {add|run|list} <command>"
    ;;
esac
