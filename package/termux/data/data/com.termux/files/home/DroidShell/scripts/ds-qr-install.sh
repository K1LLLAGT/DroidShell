#!/data/data/com.termux/files/usr/bin/bash
# ds-qr-install.sh — wireless QR installer for DroidShell APK

APK="source/DroidShell/app/build/outputs/apk/debug/app-debug.apk"

if [ ! -f "$APK" ]; then
  echo "[!] APK not found: $APK"
  exit 1
fi

echo "[+] Starting HTTP server on port 8080..."
cp "$APK" ./droidshell.apk

python3 -m http.server 8080 >/dev/null 2>&1 &
SERVER_PID=$!

sleep 1

IP=$(ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
URL="http://${IP}:8080/droidshell.apk"

echo "[+] Generating QR code for:"
echo "    $URL"

qrencode -t UTF8 "$URL"

echo "[+] Scan QR code to install."
echo "[+] Press Ctrl+C to stop server."

wait $SERVER_PID
