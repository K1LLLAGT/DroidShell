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
