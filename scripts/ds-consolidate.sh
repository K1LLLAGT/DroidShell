#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT="$HOME/DS-Build"
SRC="$ROOT/source"
SCRIPTS="$ROOT/scripts"

echo "[DroidShell] Creating canonical build directory at $ROOT"
mkdir -p "$ROOT" "$SRC" "$SCRIPTS"

# Move source repo if exists
if [ -d "$HOME/DroidShell" ]; then
    echo "[DroidShell] Moving source → $SRC"
    mv "$HOME/DroidShell" "$SRC/"
fi

# Move scripts
echo "[DroidShell] Moving scripts → $SCRIPTS"
for f in $HOME/*.sh; do
    case "$f" in
        *ds-*|*ds-*)
            mv "$f" "$SCRIPTS/"
            ;;
    esac
done

# Move docs, site, sdk-out, release-out, ds-out
[ -d "$HOME/docs" ] && mv "$HOME/docs" "$ROOT/docs"
[ -d "$HOME/site" ] && mv "$HOME/site" "$ROOT/site"
[ -d "$HOME/sdk-out" ] && mv "$HOME/sdk-out" "$ROOT/sdk-out"
[ -d "$HOME/release-out" ] && mv "$HOME/release-out" "$ROOT/release-out"
[ -d "$HOME/ds-out" ] && mv "$HOME/ds-out" "$ROOT/ds-out"

# Workspace
mkdir -p "$ROOT/workspace"

# Fix permissions
chmod -R +x "$SCRIPTS"/*.sh 2>/dev/null || true

echo "[DroidShell] Consolidation complete."
echo "[DroidShell] Build root: $ROOT"
