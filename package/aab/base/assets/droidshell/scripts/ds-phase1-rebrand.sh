#!/usr/bin/env bash
set -e

ROOT="/data/data/com.termux/files/home/DroidShell-Build"
REPO="$ROOT/source/DroidShell"

APP_ID="com.droidshell.app"
APP_NAME="DroidShell"
APP_LABEL="DroidShell"
APP_VERSION_NAME="0.119.0-droidshell"

MANIFEST="$REPO/app/src/main/AndroidManifest.xml"
STRINGS="$REPO/app/src/main/res/values/strings.xml"
BUILD_GRADLE="$REPO/app/build.gradle"
MIPMAP_DIR="$REPO/app/src/main/res/mipmap-anydpi-v26"
IC_LAUNCHER_XML="$MIPMAP_DIR/ic_launcher.xml"
README="$REPO/README.md"

echo "[ds-phase1] Phase 1: DroidShell rebrand (no package rename)"

# ---------------------------------------------------------
# 1. AndroidManifest: label → DroidShell (keep package)
# ---------------------------------------------------------
if [ -f "$MANIFEST" ]; then
    echo "[ds-phase1] Updating AndroidManifest label..."
    if grep -q 'android:label="@string/app_name"' "$MANIFEST"; then
        # already using string, fine
        :
    else
        # try to replace hardcoded label with app_name
        sed -i 's/android:label="[^"]*"/android:label="@string\/app_name"/' "$MANIFEST" || true
    fi
else
    echo "[ds-phase1] WARNING: AndroidManifest.xml not found."
fi

# ---------------------------------------------------------
# 2. strings.xml: app_name + about text
# ---------------------------------------------------------
if [ -f "$STRINGS" ]; then
    echo "[ds-phase1] Updating strings.xml..."
    # app_name
    sed -i "s#<string name=\"app_name\">.*</string>#<string name=\"app_name\">$APP_NAME</string>#" "$STRINGS"

    # about footer (idempotent)
    if ! grep -q "about_droidshell_footer" "$STRINGS"; then
        cat >> "$STRINGS" << 'EOABOUT'
<string name="about_droidshell_footer">
DroidShell — Android Terminal Emulator. Enhanced automation, startup hooks, and developer tooling.
</string>
EOABOUT
    fi
else
    echo "[ds-phase1] WARNING: strings.xml not found."
fi

# ---------------------------------------------------------
# 3. app/build.gradle: applicationId, versionName, namespace
# ---------------------------------------------------------
if [ -f "$BUILD_GRADLE" ]; then
    echo "[ds-phase1] Updating app/build.gradle..."

    # applicationId
    if grep -q 'applicationId "com.termux"' "$BUILD_GRADLE"; then
        sed -i "s/applicationId \"com.termux\"/applicationId \"$APP_ID\"/" "$BUILD_GRADLE"
    else
        sed -i "s/applicationId \".*\"/applicationId \"$APP_ID\"/" "$BUILD_GRADLE"
    fi

    # versionName
    sed -i "s/versionName \".*\"/versionName \"$APP_VERSION_NAME\"/" "$BUILD_GRADLE"

    # namespace (if present)
    if grep -q 'namespace "com.termux"' "$BUILD_GRADLE"; then
        sed -i 's/namespace "com.termux"/namespace "com.droidshell"/' "$BUILD_GRADLE"
    fi
else
    echo "[ds-phase1] WARNING: app/build.gradle not found."
fi

# ---------------------------------------------------------
# 4. Basic launcher icon XML (keep existing PNGs)
# ---------------------------------------------------------
echo "[ds-phase1] Ensuring launcher icon XML exists..."
mkdir -p "$MIPMAP_DIR"

if [ ! -f "$IC_LAUNCHER_XML" ]; then
    cat > "$IC_LAUNCHER_XML" << 'EOICON'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@android:color/black" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
EOICON
fi

# ---------------------------------------------------------
# 5. README: minimal DroidShell branding (non-destructive)
# ---------------------------------------------------------
if [ -f "$README" ]; then
    echo "[ds-phase1] Touching README.md branding..."
    if ! grep -qi "DroidShell" "$README"; then
        cat >> "$README" << 'EOREAD'

---

## DroidShell

This build is a customized fork of Termux, branded as **DroidShell**, with enhanced automation, startup hooks, and tooling.
EOREAD
    fi
fi

echo "[ds-phase1] Phase 1 rebrand complete."
