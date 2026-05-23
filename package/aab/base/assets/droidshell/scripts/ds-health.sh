#!/data/data/com.termux/files/usr/bin/bash
# ds-health.sh — system health checker

echo "[HEALTH] Checking system..."
command -v git >/dev/null || echo "[HEALTH] git missing"
command -v bash >/dev/null || echo "[HEALTH] bash missing"
command -v java >/dev/null || echo "[HEALTH] java missing"
echo "[HEALTH] Done."
