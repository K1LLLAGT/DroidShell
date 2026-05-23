#!/data/data/com.termux/files/usr/bin/bash
# ds-netmon.sh — network monitor

NET_LOG="network.log"

case "$1" in
  scan)
    echo "[NETMON] Scanning localhost ports..." | tee -a "$NET_LOG"
    netstat -tuln | tee -a "$NET_LOG"
    ;;
  log)
    cat "$NET_LOG"
    ;;
  clear)
    > "$NET_LOG"
    ;;
  *)
    echo "Usage: ds-netmon.sh {scan|log|clear}"
    ;;
esac
