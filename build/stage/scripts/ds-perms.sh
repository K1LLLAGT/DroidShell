#!/data/data/com.termux/files/usr/bin/bash
# ds-perms.sh — permissions engine

PERM_FILE="permissions.map"
touch "$PERM_FILE"

case "$1" in
  grant)
    echo "$2:$3" >> "$PERM_FILE"
    echo "[PERMS] Granted $2 → $3"
    ;;
  check)
    grep -q "$2:$3" "$PERM_FILE" && \
      echo "[PERMS] Allowed" || echo "[PERMS] Denied"
    ;;
  list)
    echo "[PERMS] Current permissions:"
    cat "$PERM_FILE"
    ;;
  *)
    echo "Usage: ds-perms.sh {grant|check|list} <subject> <action>"
    ;;
esac
