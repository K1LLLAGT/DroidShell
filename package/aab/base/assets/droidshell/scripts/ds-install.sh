#!/data/data/com.termux/files/usr/bin/bash
# ds-install.sh — one‑command installer for DroidShell OS APK

APK_PATH="source/DroidShell/app/build/outputs/apk/debug/app-debug.apk"
PKG="com.droidshell"

echo "[+] Checking APK..."
if [ ! -f "$APK_PATH" ]; then
  echo "[!] APK not found at $APK_PATH"
  exit 1
fi

echo "[+] Attempting ADB install..."
if command -v adb >/dev/null 2>&1; then
  adb install -r "$APK_PATH" && \
  adb shell am startservice -n ${PKG}/.os.OsService && \
  echo "[✓] Installed + service started via ADB" && exit 0
fi

echo "[+] ADB not available. Trying pm install..."
termux-setup-storage >/dev/null 2>&1

cp "$APK_PATH" /sdcard/Download/droidshell-latest.apk
pm install -r /sdcard/Download/droidshell-latest.apk && \
am startservice -n ${PKG}/.os.OsService && \
echo "[✓] Installed + service started via pm" && exit 0

echo "[!] Installation failed."
exit 1
