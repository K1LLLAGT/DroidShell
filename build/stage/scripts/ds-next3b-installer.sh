#!/data/data/com.termux/files/usr/bin/bash
# ds-next3b-installer.sh — generates next 3 DroidShell system scripts (scheduler, IPC bus, kernel dispatcher)

###############################################
# 1) ds-scheduler.sh — cron-like task scheduler
###############################################
echo "[+] Generating ds-scheduler.sh..."
cat << 'EOT' > ds-scheduler.sh
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
EOT


###############################################
# 2) ds-ipc.sh — inter-process communication bus
###############################################
echo "[+] Generating ds-ipc.sh..."
cat << 'EOT' > ds-ipc.sh
#!/data/data/com.termux/files/usr/bin/bash
# ds-ipc.sh — DroidShell IPC message bus

IPC_DIR="ipc"
mkdir -p "$IPC_DIR"

case "$1" in
  send)
    echo "$2" >> "$IPC_DIR/bus.msg"
    echo "[IPC] Sent message: $2"
    ;;
  recv)
    echo "[IPC] Messages:"
    cat "$IPC_DIR/bus.msg"
    ;;
  clear)
    > "$IPC_DIR/bus.msg"
    echo "[IPC] Message bus cleared."
    ;;
  *)
    echo "Usage: ds-ipc.sh {send|recv|clear} <message>"
    ;;
esac
EOT


###############################################
# 3) ds-kernel.sh — central event dispatcher
###############################################
echo "[+] Generating ds-kernel.sh..."
cat << 'EOT' > ds-kernel.sh
#!/data/data/com.termux/files/usr/bin/bash
# ds-kernel.sh — DroidShell kernel event dispatcher

EVENT_DIR="kernel/events"
mkdir -p "$EVENT_DIR"

dispatch_event() {
  echo "[KERNEL] Dispatching event: $1"
  echo "$1" >> "$EVENT_DIR/event.log"
}

case "$1" in
  fire)
    dispatch_event "$2"
    ;;
  log)
    echo "[KERNEL] Event log:"
    cat "$EVENT_DIR/event.log"
    ;;
  clear)
    > "$EVENT_DIR/event.log"
    echo "[KERNEL] Event log cleared."
    ;;
  *)
    echo "Usage: ds-kernel.sh {fire|log|clear} <event>"
    ;;
esac
EOT


###############################################
# Finalize
###############################################
echo "[+] Setting executable permissions..."
chmod +x ds-scheduler.sh
chmod +x ds-ipc.sh
chmod +x ds-kernel.sh

echo "[✓] Next 3 subsystem scripts generated successfully."
