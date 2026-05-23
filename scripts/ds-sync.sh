#!/usr/bin/env bash
# DroidShell :: scripts/ds-sync.sh
# Cross-device sync via rclone (WebDAV/cloud) or git (GitHub).
# Usage: ds-sync.sh <command> [options]
#
# Commands:
#   webdav-push [remote]   push ~/DroidShell to rclone remote (default: remote)
#   webdav-pull [remote]   pull from rclone remote
#   github-push [msg]      commit all + push
#   github-pull            git pull
#   status                 show sync status for both backends

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; N='\033[0m'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMOTE="${DROIDSHELL_REMOTE:-remote}"

cmd="${1:-help}"; shift 2>/dev/null || true

case "$cmd" in
  webdav-push)
    REMOTE="${1:-$REMOTE}"
    command -v rclone >/dev/null 2>&1 || { echo -e "${Y}[!] rclone not found. Install: pkg install rclone${N}"; exit 1; }
    echo -e "${C}[Sync]${N} Pushing to ${REMOTE}:/DroidShell ..."
    rclone copy "${BASE_DIR}/" "${REMOTE}:/DroidShell" --progress --exclude ".git/**"
    echo -e "${G}[✓] Push complete${N}"
    ;;
  webdav-pull)
    REMOTE="${1:-$REMOTE}"
    command -v rclone >/dev/null 2>&1 || { echo -e "${Y}[!] rclone not found${N}"; exit 1; }
    echo -e "${C}[Sync]${N} Pulling from ${REMOTE}:/DroidShell ..."
    rclone copy "${REMOTE}:/DroidShell" "${BASE_DIR}/" --progress
    echo -e "${G}[✓] Pull complete${N}"
    ;;
  github-push)
    MSG="${1:-Sync $(date -Iseconds)}"
    cd "$BASE_DIR"
    git add -A
    git diff --cached --quiet && { echo "[i] Nothing to commit."; exit 0; }
    git commit -m "$MSG"
    git push
    echo -e "${G}[✓] Pushed to GitHub${N}"
    ;;
  github-pull)
    cd "$BASE_DIR"
    git pull
    echo -e "${G}[✓] Pulled from GitHub${N}"
    ;;
  status)
    echo -e "${C}── Git status ─────────────────────────────────${N}"
    cd "$BASE_DIR"
    git status --short 2>/dev/null || echo "(not a git repo)"
    echo -e "${C}── rclone remotes ─────────────────────────────${N}"
    command -v rclone >/dev/null 2>&1 && rclone listremotes || echo "(rclone not installed)"
    ;;
  help|*)
    echo "DroidShell Sync"
    echo "Usage: $(basename "$0") <command> [options]"
    echo "  webdav-push [remote]  — rclone push to remote:/DroidShell"
    echo "  webdav-pull [remote]  — rclone pull from remote:/DroidShell"
    echo "  github-push [msg]     — git commit -m msg + push"
    echo "  github-pull           — git pull"
    echo "  status                — show git + rclone status"
    echo ""
    echo "  DROIDSHELL_REMOTE env var sets default rclone remote (default: 'remote')"
    ;;
esac
