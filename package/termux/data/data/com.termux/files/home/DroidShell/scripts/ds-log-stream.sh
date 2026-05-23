#!/usr/bin/env bash
# DroidShell :: scripts/ds-log-stream.sh
# Streams a log file over a WebSocket using websocat.
# Usage: ds-log-stream.sh [port] [log-file]
#   port     default: 9090
#   log-file default: ~/DroidShell/logs/droidshell.log

set -euo pipefail
C='\033[1;36m'; Y='\033[1;33m'; N='\033[0m'

PORT="${1:-9090}"
LOG_FILE="${2:-${HOME}/DroidShell/logs/droidshell.log}"

if ! command -v websocat >/dev/null 2>&1; then
  echo -e "${Y}[!] websocat not found.${N}"
  echo "    Install: pkg install websocat"
  exit 1
fi

# Create log file if it doesn't exist yet
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

echo -e "${C}[LogStream]${N} Streaming ${LOG_FILE} → ws://0.0.0.0:${PORT}"
echo -e "${C}[LogStream]${N} Connect with:  websocat ws://127.0.0.1:${PORT}"
echo -e "${C}[LogStream]${N} Press Ctrl+C to stop."

exec tail -F "$LOG_FILE" | websocat --no-close -s "tcp-l:0.0.0.0:${PORT}"
