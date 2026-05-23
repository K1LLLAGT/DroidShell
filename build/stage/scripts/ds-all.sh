#!/usr/bin/env bash
set -e

LOG="ds-all.log"
echo "[DroidShell] Starting full pipeline..." | tee "$LOG"

step() {
    echo "" | tee -a "$LOG"
    echo "=== $1 ===" | tee -a "$LOG"
}

# 1. Clone + patch Termux → DroidShell
step "1. Initializing DroidShell source tree"
./droidshell-init.sh 2>&1 | tee -a "$LOG"

# 2. Build + sign release APK
step "2. Building + signing release APK"
./droidshell-build-release.sh 2>&1 | tee -a "$LOG"

# 3. Build SDK bundle
step "3. Building SDK bundle"
./droidshell-sdk-build.sh 2>&1 | tee -a "$LOG"

# 4. Generate static website
step "4. Generating static documentation site"
./droidshell-site-build.sh 2>&1 | tee -a "$LOG"

# 5. Create full release ZIP
step "5. Creating full DroidShell release ZIP"
./droidshell-release-zip.sh 2>&1 | tee -a "$LOG"

echo "" | tee -a "$LOG"
echo "[DroidShell] Pipeline complete." | tee -a "$LOG"
echo "[DroidShell] See ds-all.log for full output." | tee -a "$LOG"
