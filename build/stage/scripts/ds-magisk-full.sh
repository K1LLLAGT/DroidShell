#!/usr/bin/env bash
# ds-magisk-full.sh
# Full Magisk module layout + overlays + boot scripts + build system.

set -euo pipefail

BANNER="
  ____            _     _ ____  _          _ _
 |  _ \ _ __ ___ (_) __| / ___|| |__   ___| | |
 | | | | '__/ _ \| |/ _\` \___ \| '_ \ / _ \ | |
 | |_| | | | (_) | | (_| |___) | | | |  __/ | |
 |____/|_|  \___/|_|\__,_|____/|_| |_|\___|_|_|
  Magisk Full  · overlays · boot · build
"

echo "$BANNER"
echo

BASE_DIR="$(pwd)"
MAGISK_DIR="$BASE_DIR/magisk-droidshell"
SYS_DIR="$MAGISK_DIR/system"
OVL_DIR="$SYS_DIR/overlay"
ETC_DIR="$SYS_DIR/etc"
BIN_DIR="$SYS_DIR/bin"
SCRIPT_DIR="$BASE_DIR/scripts"

mkdir -p "$MAGISK_DIR" "$OVL_DIR" "$ETC_DIR" "$BIN_DIR" "$SCRIPT_DIR"

############################################
# 1) module.prop
############################################
cat << 'MP' > "$MAGISK_DIR/module.prop"
id=droidshell
name=DroidShell System Diagnostic Layer
version=1.0.0
versionCode=1
author=Greg
description=DroidShell as a Magisk-based system diagnostic layer with overlays and boot-time services.
MP
echo "[GEN] module.prop"

############################################
# 2) Boot-time scripts: service.sh + post-fs-data.sh
############################################
cat << 'SV' > "$MAGISK_DIR/service.sh"
#!/system/bin/sh
MODDIR=${0%/*}

log -t droidshell "DroidShell Magisk service starting: $MODDIR"

# Example: ensure a runtime dir for logs/state
mkdir -p /data/local/tmp/droidshell
chmod 755 /data/local/tmp/droidshell

# Hook: if DroidShell root API exists, you could start a background service here.
# (Kept as a placeholder to avoid long-running daemons by default.)
# /data/local/tmp/droidshell/api.sh &

log -t droidshell "DroidShell Magisk service finished init."
SV
chmod 0755 "$MAGISK_DIR/service.sh"
echo "[GEN] service.sh"

cat << 'PF' > "$MAGISK_DIR/post-fs-data.sh"
#!/system/bin/sh
MODDIR=${0%/*}

log -t droidshell "DroidShell post-fs-data: $MODDIR"

# Placeholder: early-mount or early-config hooks can go here.
# Kept minimal and non-destructive.
PF
chmod 0755 "$MAGISK_DIR/post-fs-data.sh"
echo "[GEN] post-fs-data.sh"

############################################
# 3) System overlay templates (UI/config)
############################################

# Simple overlay placeholder (RRO/OMS style directory)
OVL_PKG_DIR="$OVL_DIR/DroidShellOverlay"
mkdir -p "$OVL_PKG_DIR/res/values"

cat << 'OVM' > "$OVL_PKG_DIR/AndroidManifest.xml"
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.droidshell.overlay"
    android:versionCode="1"
    android:versionName="1.0">
    <overlay
        android:targetPackage="android"
        android:priority="1"
        android:isStatic="true" />
</manifest>
OVM

cat << 'OVV' > "$OVL_PKG_DIR/res/values/droidshell_overlay.xml"
<resources>
    <!-- Example placeholder: you can define colors, bools, dimensions, etc.
         This file is a template and does not change behavior by default. -->
    <bool name="droidshell_overlay_enabled">true</bool>
</resources>
OVV

echo "[GEN] system overlay template → $OVL_PKG_DIR"

# Config templates under /system/etc
cat << 'ETC1' > "$ETC_DIR/droidshell-debug.conf"
# DroidShell debug configuration template
# This file is a placeholder for future system-level debug toggles.
# It is not consumed by the system by default.
enable_extended_logging=false
ETC1

cat << 'ETC2' > "$ETC_DIR/droidshell-thermal.conf"
# DroidShell thermal configuration template
# Placeholder for future thermal/diagnostic overlays.
thermal_profile=default
ETC2

echo "[GEN] system config templates → $ETC_DIR"

############################################
# 4) System-level helper binary wrapper (optional)
############################################
cat << 'BIN' > "$BIN_DIR/droidshell-cli"
#!/system/bin/sh
# System-level entrypoint for DroidShell (Magisk-mounted).
# This can be used from adb shell or other tools.

if [ -x /data/data/com.termux/files/home/DroidShell/ds_root.sh ]; then
  /data/data/com.termux/files/home/DroidShell/ds_root.sh "$@"
elif [ -x /sdcard/Documents/DroidShell/ds_root.sh ]; then
  /sdcard/Documents/DroidShell/ds_root.sh "$@"
else
  echo "DroidShell root console not found."
  exit 1
fi
BIN
chmod 0755 "$BIN_DIR/droidshell-cli"
echo "[GEN] system binary wrapper → $BIN_DIR/droidshell-cli"

############################################
# 5) Build system: create flashable Magisk ZIP
############################################
cat << 'BLD' > "$SCRIPT_DIR/build-magisk-droidshell.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAGISK_DIR="$BASE_DIR/magisk-droidshell"
OUT_DIR="$BASE_DIR/out"
mkdir -p "$OUT_DIR"

VERSION_FILE="$MAGISK_DIR/module.prop"
VERSION="1.0.0"

if [ -f "$VERSION_FILE" ]; then
  VERSION=$(grep '^version=' "$VERSION_FILE" | cut -d'=' -f2- || echo "1.0.0")
fi

ZIP_NAME="droidshell-magisk-$VERSION.zip"
ZIP_PATH="$OUT_DIR/$ZIP_NAME"

echo "[+] Building Magisk module ZIP: $ZIP_PATH"

cd "$MAGISK_DIR"
# Standard Magisk module zip layout: contents of magisk-droidshell at root of zip
zip -r "$ZIP_PATH" . >/dev/null

echo "[✓] Built: $ZIP_PATH"
BLD
chmod +x "$SCRIPT_DIR/build-magisk-droidshell.sh"
echo "[GEN] build-magisk-droidshell.sh"

############################################
# 6) Summary
############################################
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Magisk Full Layout — Generated"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Module dir: $MAGISK_DIR"
echo " Build script: $SCRIPT_DIR/build-magisk-droidshell.sh"
echo
echo "To build flashable ZIP:"
echo "  $SCRIPT_DIR/build-magisk-droidshell.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
