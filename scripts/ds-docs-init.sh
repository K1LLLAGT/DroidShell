#!/data/data/com.termux/files/usr/bin/bash
set -e

DOCS="docs"
mkdir -p "$DOCS"

echo "[DroidShell] Creating documentation tree at $DOCS"

# index.md
cat > "$DOCS/index.md" << 'EOINDEX'
# DroidShell Documentation

Welcome to the official DroidShell documentation.
EOINDEX

# install.md
cat > "$DOCS/install.md" << 'EOINST'
# Installing DroidShell

Use:
    ./install-droidshell.sh <apk>
EOINST

# config.md
cat > "$DOCS/config.md" << 'EOCFG'
# DroidShell Configuration

Config root:
    ~/.droidshell/etc/
EOCFG

# plugins.md
cat > "$DOCS/plugins.md" << 'EOPLUG'
# DroidShell Plugins

Plugins live in:
    ~/.droidshell/plugins/
EOPLUG

# themes.md
cat > "$DOCS/themes.md" << 'EOTHEME'
# DroidShell Themes

Themes stored in:
    ~/.droidshell/etc/colors/
EOTHEME

# tools.md
cat > "$DOCS/tools.md" << 'EOTOOLS'
# DroidShell Tools

Tools installed under:
    ~/.droidshell/usr/bin/
EOTOOLS

echo "[DroidShell] Documentation tree created."
