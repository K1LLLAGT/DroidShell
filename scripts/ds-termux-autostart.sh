#!/data/data/com.termux/files/usr/bin/bash
# ds-termux-autostart.sh — install + start DroidShell OS from Termux

APK="source/DroidShell/app/build/outputs/apk/debug/app-debug.apk"
PKG="com.droidshell"

termux-setup-storage >/dev/null 2>&1

echo "[+] Copying APK to /sdcard/Download..."
cp "$APK" /sdcard/Download/droidshell-latest.apk

echo "[+] Installing..."
pm install -r /sdcard/Download/droidshell-latest.apk || {
  echo "[!] Install failed"
  exit 1
}

echo "[+] Starting OS service..."
am startservice -n ${PKG}/.os.OsService

echo "[✓] DroidShell OS installed + service running."
