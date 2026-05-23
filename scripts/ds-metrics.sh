#!/data/data/com.termux/files/usr/bin/bash
# ds-metrics.sh — metrics collector

METRICS_FILE="metrics.data"

collect() {
  echo "timestamp=$(date +%s)" >> "$METRICS_FILE"
  echo "cpu=$(top -b -n 1 | head -3 | tail -1)" >> "$METRICS_FILE"
}

case "$1" in
  collect) collect ;;
  show) cat "$METRICS_FILE" ;;
  clear) > "$METRICS_FILE" ;;
  *)
    echo "Usage: ds-metrics.sh {collect|show|clear}"
    ;;
esac
