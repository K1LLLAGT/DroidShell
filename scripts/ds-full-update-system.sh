#!/usr/bin/env bash
# ds-full-update-system.sh
# Creates: background update checker, update dialog, QR installer,
# nightly build workflow, release notes generator.

set -euo pipefail

echo "[+] Creating scripts directory..."
mkdir -p scripts
mkdir -p .github/workflows

###############################################
# 1. Background Update Checker
###############################################
echo "[+] Creating background update checker..."

cat << 'SH' > scripts/ds-update-checker.sh
#!/usr/bin/env bash
# ds-update-checker.sh
# Checks GitHub Releases for a newer version.

set -euo pipefail

REPO="K1LLLAGT/DroidShell"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

LATEST=$(curl -s $API_URL | grep tag_name | cut -d '"' -f 4)
CURRENT=$(grep versionName source/DroidShell/app/build.gradle | cut -d '"' -f 2)

if [ "$LATEST" != "$CURRENT" ]; then
  echo "update_available=true" > ~/.droidshell-update
else
  echo "update_available=false" > ~/.droidshell-update
fi
SH

chmod +x scripts/ds-update-checker.sh


###############################################
# 2. In-App Update Dialog (shell-triggered)
###############################################
echo "[+] Creating in-app update dialog trigger..."

cat << 'SH' > scripts/ds-update-dialog.sh
#!/usr/bin/env bash
# ds-update-dialog.sh
# Reads update flag and prints dialog instructions.

FLAG=~/.droidshell-update

if [ ! -f "$FLAG" ]; then
  echo "No update check performed yet."
  exit 0
fi

if grep -q "true" "$FLAG"; then
  echo "UPDATE_AVAILABLE"
else
  echo "NO_UPDATE"
fi
SH

chmod +x scripts/ds-update-dialog.sh


###############################################
# 3. QR Installer for Latest Release
###############################################
echo "[+] Creating QR installer..."

cat << 'SH' > scripts/ds-qr-installer.sh
#!/usr/bin/env bash
# ds-qr-installer.sh
# Generates a QR code that installs the latest APK.

set -euo pipefail

REPO="K1LLLAGT/DroidShell"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

APK_URL=$(curl -s $API_URL | grep browser_download_url | grep .apk | cut -d '"' -f 4)

if [ -z "$APK_URL" ]; then
  echo "[!] No APK found."
  exit 1
fi

echo "[+] Generating QR code..."
echo "$APK_URL" | qrencode -o droidshell-latest.png

echo "[✓] QR code saved as droidshell-latest.png"
SH

chmod +x scripts/ds-qr-installer.sh


###############################################
# 4. Nightly Build Workflow
###############################################
echo "[+] Creating nightly build workflow..."

cat << 'YAML' > .github/workflows/nightly.yml
name: Nightly Build

on:
  schedule:
    - cron: "0 3 * * *"   # 3 AM UTC nightly
  workflow_dispatch:

jobs:
  nightly:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Set up JDK
      uses: actions/setup-java@v4
      with:
        distribution: temurin
        java-version: 17

    - name: Build Release APK
      working-directory: source/DroidShell
      run: ./gradlew :app:assembleRelease

    - name: Upload Nightly Artifact
      uses: actions/upload-artifact@v4
      with:
        name: droidshell-nightly
        path: source/DroidShell/app/build/outputs/apk/release/*.apk
YAML


###############################################
# 5. Release Notes Generator Workflow
###############################################
echo "[+] Creating release notes generator..."

cat << 'YAML' > .github/workflows/release-notes.yml
name: Release Notes Generator

on:
  push:
    tags:
      - "v*"

jobs:
  notes:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Generate Release Notes
      id: notes
      run: |
        echo "notes<<EOF" >> $GITHUB_OUTPUT
        git log -1 --pretty=format:"%h - %s"
        echo "EOF" >> $GITHUB_OUTPUT

    - name: Create GitHub Release
      uses: softprops/action-gh-release@v2
      with:
        body: ${{ steps.notes.outputs.notes }}
        files: source/DroidShell/app/build/outputs/apk/release/*.apk
YAML


###############################################
# Final Output
###############################################
echo "[✓] All update + CI systems created."
echo "[✓] Background checker, update dialog, QR installer, nightly workflow, release notes workflow."
