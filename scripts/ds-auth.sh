#!/data/data/com.termux/files/usr/bin/bash
# ds-auth.sh — authentication stub

AUTH_FILE="auth.users"
touch "$AUTH_FILE"

case "$1" in
  add)
    echo "$2" >> "$AUTH_FILE"
    echo "[AUTH] Added user: $2"
    ;;
  verify)
    grep -q "$2" "$AUTH_FILE" && \
      echo "[AUTH] Verified" || echo "[AUTH] Unknown user"
    ;;
  list)
    echo "[AUTH] Registered users:"
    cat "$AUTH_FILE"
    ;;
  *)
    echo "Usage: ds-auth.sh {add|verify|list} <user>"
    ;;
esac
