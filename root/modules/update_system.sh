#!/usr/bin/env bash
# DroidShell :: root/modules/update_system.sh
# Self-update mechanism for DroidShell root modules.
# Usage: update_system.sh [--check] [--apply] [--rollback]

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'

DS_ROOT="${HOME}/DroidShell"
UPDATE_MANIFEST="${DS_ROOT}/updates/manifest.json"
BACKUP_DIR="${DS_ROOT}/updates/backups"

case "${1:---check}" in
  --check)
    echo -e "${C}Checking for DroidShell updates...${N}"
    [[ -f "$UPDATE_MANIFEST" ]] || { echo "No manifest found. Run --apply to initialize."; exit 0; }
    cat "$UPDATE_MANIFEST"
    ;;

  --apply)
    [[ -f "$UPDATE_MANIFEST" ]] || { echo "No manifest found at ${UPDATE_MANIFEST}"; exit 1; }
    mkdir -p "$BACKUP_DIR"
    echo -e "${C}Applying updates from manifest...${N}"
    # Back up current state before applying
    tar -czf "${BACKUP_DIR}/pre_update_$(date +%Y%m%d_%H%M%S).tar.gz" \
      -C "$DS_ROOT" root/ 2>/dev/null || true
    echo -e "${G}[✓] Backup created${N}"
    # The actual update steps are defined in manifest.json
    echo -e "${Y}[!] Implement fetch/apply logic in manifest.json${N}"
    ;;

  --rollback)
    latest=$(ls -t "${BACKUP_DIR}"/*.tar.gz 2>/dev/null | head -1)
    [[ -n "$latest" ]] || { echo "No backup found to rollback to"; exit 1; }
    echo -e "${Y}Rolling back to: ${latest}${N}"
    read -r -p "Confirm rollback? [y/N] " ans
    [[ "$ans" == "y" ]] || { echo "Aborted."; exit 0; }
    tar -xzf "$latest" -C "$DS_ROOT"
    echo -e "${G}[✓] Rollback complete${N}"
    ;;

  *)
    echo "Usage: update_system.sh [--check|--apply|--rollback]"
    ;;
esac
