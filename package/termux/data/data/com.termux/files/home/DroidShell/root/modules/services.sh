#!/usr/bin/env bash
set -euo pipefail
CMD="${1:-list}"
case "$CMD" in
  list) su -c "service list" ;;
  raw) shift; su -c "service $*" ;;
  *) echo "Usage: $0 [list|raw]" ;;
esac
