#!/usr/bin/env bash
set -e

ROOT="/data/data/com.termux/files/home/DroidShell-Build"
REPO="$ROOT/source/DroidShell"
ACT="$REPO/app/src/main/java/com/termux/app/TermuxActivity.java"
IDS="$REPO/app/src/main/res/values/ids.xml"

echo "[ds-check] Checking DroidShell repo integrity..."

# 1. Repo exists
if [ ! -d "$REPO/.git" ]; then
    echo "[ERROR] Repo missing: $REPO"
    exit 1
fi
echo "[OK] Repo exists."

# 2. TermuxActivity exists
if [ ! -f "$ACT" ]; then
    echo "[ERROR] TermuxActivity.java missing."
    exit 1
fi
echo "[OK] TermuxActivity.java found."

# 3. Menu item injected
if grep -q "action_droidshell_tools" "$ACT"; then
    echo "[OK] Menu item injection detected."
else
    echo "[WARN] Menu item NOT injected."
fi

# 4. Handler injected
if grep -q "showDroidShellTools()" "$ACT"; then
    echo "[OK] Handler injection detected."
else
    echo "[WARN] Handler NOT injected."
fi

# 5. Startup hook
if grep -q "runDroidShellStartupScript" "$ACT"; then
    echo "[OK] Startup hook detected."
else
    echo "[WARN] Startup hook missing."
fi

# 6. ids.xml
if [ -f "$IDS" ] && grep -q "action_droidshell_tools" "$IDS"; then
    echo "[OK] ids.xml contains action_droidshell_tools."
else
    echo "[WARN] ids.xml missing or incomplete."
fi

echo "[ds-check] Complete."
