#!/usr/bin/env bash
set -euo pipefail
CMD="${1:-list}"
case "$CMD" in
  list) su -c "getprop" ;;
  get) su -c "getprop \"$2\"" ;;
  set) su -c "resetprop \"$2\" \"$3\"" ;;
  *) echo "Usage: $0 [list|get|set]" ;;
esac
