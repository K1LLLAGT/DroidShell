#!/usr/bin/env bash
# ds-build-and-update-system.sh
# Creates GitHub-only build workflow + Termux latest-release installer

set -euo pipefail

echo "[+] Creating GitHub-only build workflow..."
mkdir -p .github/workflows

cat << 'YAML' > .github/workflows/github-only-build.yml
name: DroidShell CI Build

on:
  push:
    branches: [ "main" ]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Set up JDK
      uses: actions/setup-java@v4
      with:
        distribution: temurin
        java-version: 17

    - name: Make Gradle executable
      run: chmod +x ./source/DroidShell/gradlew

    - name: Build Release APK
      working-directory: source/DroidShell
      run: ./gradlew :app:assembleRelease

    - name: Upload Artifact
      uses: actions/upload-artifact@v4
      with:
        name: droidshell-release
        path: source/DroidShell/app/build/outputs/apk/release/*.apk
YAML

echo "[+] Creating Termux latest-release installer..."
mkdir -p scripts

cat << 'SH' > scripts/ds-latest-release.sh
#!/usr/bin/env bash
# ds-latest-release.sh
# Downloads and installs the latest DroidShell release APK

set -euo pipefail

REPO="K1LLLAGT/DroidShell"

echo "[+] Fetching latest release info..."
API_URL="https://api.github.com/repos/$REPO/releases/latest"
APK_URL=$(curl -s $API_URL | grep browser_download_url | grep .apk | cut -d '"' -f 4)

if [ -z "$APK_URL" ]; then
  echo "[!] No APK found in latest release."
  exit 1
fi

echo "[+] Downloading APK:"
echo "    $APK_URL"
curl -L "$APK_URL" -o droidshell-latest.apk

echo "[+] Installing APK..."
pm install -r droidshell-latest.apk

echo "[✓] DroidShell updated to latest release."
SH

chmod +x scripts/ds-latest-release.sh

echo "[+] Done."
echo "[✓] GitHub-only build workflow created."
echo "[✓] Termux latest-release installer created."
