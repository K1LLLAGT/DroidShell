#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-info}"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

case "$CMD" in
  info)
    OEM=$(su -c "getprop ro.product.manufacturer 2>/dev/null" || echo "unknown")
    MODEL=$(su -c "getprop ro.product.model 2>/dev/null" || echo "unknown")
    ANDROID=$(su -c "getprop ro.build.version.release 2>/dev/null" || echo "unknown")
    ROOT="false"
    if command -v su >/dev/null 2>&1; then ROOT="true"; fi
    echo "{"
    echo "  \"oem\": \"$(json_escape "$OEM")\","
    echo "  \"model\": \"$(json_escape "$MODEL")\","
    echo "  \"android\": \"$(json_escape "$ANDROID")\","
    echo "  \"root\": $ROOT"
    echo "}"
    ;;
  *)
    echo "Usage: $0 info"
    exit 1
    ;;
esac
