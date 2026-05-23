#!/usr/bin/env bash
set -euo pipefail

ds_widget_battery() {
  echo "[Battery]"
  su -c "dumpsys battery 2>/dev/null | sed 's/^/  /'" || echo "  (no dumpsys battery)"
  echo
}

ds_widget_selinux() {
  echo "[SELinux]"
  su -c "getenforce 2>/dev/null | sed 's/^/  Mode: /'" || echo "  (no getenforce)"
  echo
}

ds_widget_magisk() {
  echo "[Magisk]"
  if su -c "magisk -v" >/dev/null 2>&1; then
    su -c "magisk -v 2>/dev/null | sed 's/^/  /'"
  else
    echo "  Magisk: not detected"
  fi
  echo
}
