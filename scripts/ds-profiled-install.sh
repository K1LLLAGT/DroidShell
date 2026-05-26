#!/usr/bin/env bash
# Installs DroidShell profile.d integration into all shell configs.

set -e

ROOT="/sdcard/DroidShell"
PROF="$ROOT/scripts/ds-profiled.sh"

patch() {
    local file="$1"
    [ ! -f "$file" ] && return
    if grep -q "ds-profiled.sh" "$file"; then
        echo "  [OK] $file already patched"
    else
        echo "source $PROF" >> "$file"
        echo "  [PATCHED] $file"
    fi
}

echo "[DroidShell] Installing profile.d integration..."

patch "$HOME/.profile"
patch "$HOME/.bashrc"
patch "$HOME/.bash_profile"
patch "$HOME/.zshrc"

echo "[DroidShell] profile.d integration complete."
