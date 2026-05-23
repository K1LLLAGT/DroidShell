#!/usr/bin/env bash
# ds-github-secrets.sh
# Generates Android signing keystore + Base64 + prints GitHub Actions secrets.

set -euo pipefail

OUTDIR="keystore"
mkdir -p "$OUTDIR"

KEYSTORE="$OUTDIR/droidshell-release.keystore"
BASE64FILE="$OUTDIR/droidshell-release.keystore.base64"
ALIAS="droidshell"

echo "============================================================"
echo "   DroidShell GitHub Actions Secret Generator"
echo "============================================================"
echo ""
echo "[+] Generating Android signing keystore..."
echo "    Location: $KEYSTORE"
echo ""

keytool -genkeypair \
  -v \
  -keystore "$KEYSTORE" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

echo ""
echo "[+] Encoding keystore to Base64..."
base64 "$KEYSTORE" > "$BASE64FILE"

echo ""
echo "============================================================"
echo "   COPY THESE VALUES INTO GITHUB → Settings → Secrets → Actions"
echo "============================================================"
echo ""

echo "1) ANDROID_KEYSTORE_BASE64"
echo "------------------------------------------------------------"
cat "$BASE64FILE"
echo ""
echo ""

echo "2) ANDROID_KEY_ALIAS"
echo "------------------------------------------------------------"
echo "$ALIAS"
echo ""
echo ""

echo "3) ANDROID_KEYSTORE_PASSWORD"
echo "------------------------------------------------------------"
echo "The password you entered during keytool generation."
echo ""
echo ""

echo "4) ANDROID_KEY_PASSWORD"
echo "------------------------------------------------------------"
echo "The key password (may be same as keystore password)."
echo ""
echo ""

echo "============================================================"
echo "   DONE. Your keystore + Base64 output is in: $OUTDIR/"
echo "============================================================"
