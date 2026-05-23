#!/usr/bin/env bash
set -e

REPO="DroidShell"
OUT="../ds-out"
KEYSTORE="$OUT/ds-release.keystore"
ALIAS="droidshell"
PASS="droidshellpass"

if [ ! -d "$REPO" ]; then
    echo "[DroidShell] Repo not found. Run init first."
    exit 1
fi

cd "$REPO"

mkdir -p "$OUT"

echo "[DroidShell] Building debug APK..."
./gradlew assembleDebug

echo "[DroidShell] Building release APK..."
./gradlew assembleRelease

# Generate keystore if missing
if [ ! -f "$KEYSTORE" ]; then
    echo "[DroidShell] Generating keystore..."
    keytool -genkey -v \
        -keystore "$KEYSTORE" \
        -alias "$ALIAS" \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -storepass "$PASS" -keypass "$PASS" \
        -dname "CN=DroidShell,O=DroidShell,C=US"
fi

APK_RELEASE="app/build/outputs/apk/release/app-release-unsigned.apk"
APK_SIGNED="$OUT/ds-release-signed.apk"

echo "[DroidShell] Signing release APK..."
apksigner sign \
    --ks "$KEYSTORE" \
    --ks-pass pass:"$PASS" \
    --key-pass pass:"$PASS" \
    --out "$APK_SIGNED" \
    "$APK_RELEASE"

echo "[DroidShell] Build + signing complete."
echo "Signed APK: $APK_SIGNED"
