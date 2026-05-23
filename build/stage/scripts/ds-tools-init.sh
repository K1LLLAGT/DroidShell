#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="$HOME/.droidshell/usr/bin"
mkdir -p "$BASE"

echo "[DroidShell] Installing /usr/bin tool suite at $BASE"

# ds-info
cat > "$BASE/ds-info" << 'EOINFO'
#!/bin/bash
echo "DroidShell System Info"
echo "----------------------"
echo "Android: $(getprop ro.build.version.release)"
echo "Device:  $(getprop ro.product.model)"
echo "ABI:     $(getprop ro.product.cpu.abi)"
EOINFO
chmod +x "$BASE/ds-info"

# ds-update
cat > "$BASE/ds-update" << 'EOUP'
#!/bin/bash
APK="$1"
if [ -z "$APK" ]; then
    echo "Usage: ds-update <apk>"
    exit 1
fi
pm install -r "$APK"
echo "DroidShell updated."
EOUP
chmod +x "$BASE/ds-update"

# ds-plugins
cat > "$BASE/ds-plugins" << 'EOPLUG'
#!/bin/bash
DIR="$HOME/.droidshell/plugins"
mkdir -p "$DIR"
echo "Installed plugins:"
ls "$DIR"
EOPLUG
chmod +x "$BASE/ds-plugins"

# ds-theme
cat > "$BASE/ds-theme" << 'EOTHEME'
#!/bin/bash
THEME="$1"
if [ -z "$THEME" ]; then
    echo "Usage: ds-theme <theme-name>"
    exit 1
fi
echo "theme=$THEME" > "$HOME/.droidshell/etc/system/defaults.conf"
echo "Theme set to $THEME"
EOTHEME
chmod +x "$BASE/ds-theme"

# ds-shell
cat > "$BASE/ds-shell" << 'EOSH'
#!/bin/bash
echo "Launching DroidShell..."
bash
EOSH
chmod +x "$BASE/ds-shell"

echo "[DroidShell] Tool suite installed."
