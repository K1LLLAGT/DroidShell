#!/data/data/com.termux/files/usr/bin/bash
set -e

CMD="$1"
BACKUP_DIR="$HOME/.droidshell-backups"
TS=$(date +"%Y%m%d-%H%M%S")

mkdir -p "$BACKUP_DIR"

backup() {
    DEST="$BACKUP_DIR/backup-$TS"
    mkdir -p "$DEST"

    echo "[DroidShell] Backing up configs to $DEST"

    cp -a "$HOME/.droidshell-startup" "$DEST/" 2>/dev/null || true
    cp -a "$HOME/.droidshell" "$DEST/" 2>/dev/null || true
    cp -a "$HOME/.droidshell/plugins" "$DEST/" 2>/dev/null || true
    cp -a "$HOME/.termux/colors.properties" "$DEST/" 2>/dev/null || true
    cp -a "$HOME/.termux/termux.properties" "$DEST/" 2>/dev/null || true

    echo "[DroidShell] Backup complete."
}

restore() {
    SRC="$2"
    if [ -z "$SRC" ]; then
        echo "[DroidShell] Usage: ./droidshell-backup-restore.sh restore <backup-folder>"
        exit 1
    fi

    if [ ! -d "$SRC" ]; then
        echo "[DroidShell] ERROR: Backup folder not found: $SRC"
        exit 1
    fi

    echo "[DroidShell] Restoring from $SRC"

    cp -a "$SRC/.droidshell-startup" "$HOME/" 2>/dev/null || true
    cp -a "$SRC/.droidshell" "$HOME/" 2>/dev/null || true
    cp -a "$SRC/plugins" "$HOME/.droidshell/" 2>/dev/null || true
    cp -a "$SRC/colors.properties" "$HOME/.termux/" 2>/dev/null || true
    cp -a "$SRC/termux.properties" "$HOME/.termux/" 2>/dev/null || true

    echo "[DroidShell] Restore complete."
}

case "$CMD" in
    backup) backup ;;
    restore) restore "$@" ;;
    *)
        echo "[DroidShell] Usage:"
        echo "  ./droidshell-backup-restore.sh backup"
        echo "  ./droidshell-backup-restore.sh restore <backup-folder>"
        exit 1
        ;;
esac
