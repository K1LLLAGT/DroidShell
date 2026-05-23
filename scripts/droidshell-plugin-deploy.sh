#!/data/data/com.termux/files/usr/bin/bash
set -e

PLUGIN="$1"
DEST="$HOME/.droidshell/plugins"
REG="$HOME/.droidshell/etc/plugins/registry.txt"

if [ -z "$PLUGIN" ]; then
    echo "[DroidShell] Usage: ./droidshell-plugin-deploy.sh <plugin.jar>"
    exit 1
fi

if [ ! -f "$PLUGIN" ]; then
    echo "[DroidShell] ERROR: Plugin not found: $PLUGIN"
    exit 1
fi

mkdir -p "$DEST"
mkdir -p "$(dirname "$REG")"

NAME=$(basename "$PLUGIN")

echo "[DroidShell] Deploying plugin: $NAME"
cp "$PLUGIN" "$DEST/"

echo "[DroidShell] Updating registry..."
echo "$NAME $(date)" >> "$REG"

echo "[DroidShell] Plugin deployed to $DEST"
