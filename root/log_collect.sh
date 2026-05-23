#!/usr/bin/env bash
# DroidShell :: root/log_collect.sh
# Collects logcat (full), dmesg, and /proc/kmsg as root.
# Usage: log_collect.sh [--out <dir>] [--duration <secs>] [--buffers <list>]

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; N='\033[0m'

OUT_DIR="${HOME}/DroidShell/logs/$(date +%Y%m%d_%H%M%S)"
DURATION=30
BUFFERS="main,system,crash,kernel,radio,events"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)      OUT_DIR="$2";  shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    --buffers)  BUFFERS="$2";  shift 2 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }
mkdir -p "$OUT_DIR"

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║      DroidShell Log Collector            ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"
echo -e "${C}Output  : ${OUT_DIR}${N}"
echo -e "${C}Duration: ${DURATION}s  |  Buffers: ${BUFFERS}${N}"
echo ""

# ── logcat (full, all buffers, root) ─────────────────────────────────────────
echo -e "${G}[1/3]${N} logcat..."
su -c "logcat -b ${BUFFERS} -d" > "${OUT_DIR}/logcat_dump.txt" 2>&1 &
LOG_PID=$!
sleep "$DURATION"
kill "$LOG_PID" 2>/dev/null || true
wait "$LOG_PID" 2>/dev/null || true
lines=$(wc -l < "${OUT_DIR}/logcat_dump.txt")
echo -e "      → ${lines} lines → logcat_dump.txt"

# ── dmesg ─────────────────────────────────────────────────────────────────────
echo -e "${G}[2/3]${N} dmesg..."
su -c "dmesg -T" > "${OUT_DIR}/dmesg.txt" 2>&1
lines=$(wc -l < "${OUT_DIR}/dmesg.txt")
echo -e "      → ${lines} lines → dmesg.txt"

# ── /proc/kmsg ────────────────────────────────────────────────────────────────
echo -e "${G}[3/3]${N} /proc/kmsg (${DURATION}s)..."
( su -c "cat /proc/kmsg" > "${OUT_DIR}/kmsg.txt" 2>&1 & KPID=$!; \
  sleep "$DURATION"; kill "$KPID" 2>/dev/null; wait "$KPID" 2>/dev/null; \
  echo -e "      → $(wc -l < "${OUT_DIR}/kmsg.txt") lines → kmsg.txt" )

# ── Metadata ──────────────────────────────────────────────────────────────────
{
  echo "# DroidShell Log Collection Metadata"
  echo "# Generated : $(date -Iseconds)"
  echo "# Duration  : ${DURATION}s"
  echo "# Buffers   : ${BUFFERS}"
  echo "# Android   : $(su -c 'getprop ro.build.version.release' 2>/dev/null || echo unknown)"
  echo "# SDK       : $(su -c 'getprop ro.build.version.sdk'     2>/dev/null || echo unknown)"
  echo "# Device    : $(su -c 'getprop ro.product.model'         2>/dev/null || echo unknown)"
  echo "# Build     : $(su -c 'getprop ro.build.id'              2>/dev/null || echo unknown)"
} > "${OUT_DIR}/metadata.txt"

echo -e "\n${C}══ Log collection complete → ${OUT_DIR} ══${N}"
