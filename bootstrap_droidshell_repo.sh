#!/usr/bin/env bash
set -euo pipefail

# bootstrap_droidshell_repo.sh
# Creates a full DroidShell repo from scratch.

ROOT_DIR="${1:-DroidShell}"

echo "=== Bootstrapping DroidShell repo at: $ROOT_DIR ==="
mkdir -p "$ROOT_DIR"
cd "$ROOT_DIR"

###############################################
# 1) build_droidshell_os.sh
###############################################
cat > build_droidshell_os.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# build_droidshell_os.sh
# Full unified builder for the DroidShell OS layer + APK resource stubs.

PUBLIC_ROOT="${1:-/sdcard/DroidShell}"
INTERNAL_ROOT="${2:-./DroidShell_internal}"
APK_RES_ROOT="${3:-./APK_Resources}"

echo "=== DroidShell OS Layer Builder ==="
echo "Public root:   $PUBLIC_ROOT"
echo "Internal root: $INTERNAL_ROOT"
echo "APK res root:  $APK_RES_ROOT"
echo

mkdir -p "$PUBLIC_ROOT" "$INTERNAL_ROOT" "$APK_RES_ROOT/drawable" "$APK_RES_ROOT/raw"

build_root() {
  local ROOT="$1"
  echo "-> Provisioning: $ROOT"

  mkdir -p \
    "$ROOT/bin" \
    "$ROOT/plugins" \
    "$ROOT/themes" \
    "$ROOT/scripts" \
    "$ROOT/workspace" \
    "$ROOT/packages" \
    "$ROOT/config" \
    "$ROOT/logs"

  # bin
  cat > "$ROOT/bin/droidshell-env.sh" <<'EOB'
#!/usr/bin/env sh
echo "DroidShell Environment:"
echo "PWD: $(pwd)"
echo "USER: $(whoami 2>/dev/null || echo unknown)"
EOB
  chmod +x "$ROOT/bin/droidshell-env.sh"

  cat > "$ROOT/bin/droidshell-version.sh" <<'EOB'
#!/usr/bin/env sh
echo "DroidShell OS Layer"
echo "Version: 0.1.0-dev"
EOB
  chmod +x "$ROOT/bin/droidshell-version.sh"

  cat > "$ROOT/bin/droidshell-diagnostics.sh" <<'EOB'
#!/usr/bin/env sh
echo "=== DroidShell Diagnostics ==="
echo "Date: $(date 2>/dev/null || echo unknown)"
echo "Uname: $(uname -a 2>/dev/null || echo unknown)"
echo "Shell: $SHELL"
echo "PATH: $PATH"
EOB
  chmod +x "$ROOT/bin/droidshell-diagnostics.sh"

  # plugins
  mkdir -p "$ROOT/plugins/example"
  cat > "$ROOT/plugins/example/manifest.json" <<'EOB'
{
  "id": "example",
  "name": "Example Plugin",
  "version": "0.1.0",
  "description": "Sample DroidShell plugin for validation and testing.",
  "entry": "plugin.sh"
}
EOB

  cat > "$ROOT/plugins/example/plugin.sh" <<'EOB'
#!/usr/bin/env sh
echo "[Example Plugin] Hello from DroidShell plugin!"
echo "[Example Plugin] Working directory: $(pwd)"
EOB
  chmod +x "$ROOT/plugins/example/plugin.sh"

  # themes
  cat > "$ROOT/themes/default.json" <<'EOB'
{
  "name": "Default",
  "accent": "#00FF7F",
  "background": "#101010",
  "title": "#FFFFFF",
  "tint": "#00FF7F"
}
EOB

  # scripts
  cat > "$ROOT/scripts/test.sh" <<'EOB'
#!/usr/bin/env sh
echo "[DroidShell Test Script]"
echo "PWD: $(pwd)"
echo "ARGS: $@"
EOB
  chmod +x "$ROOT/scripts/test.sh"

  cat > "$ROOT/scripts/hello.sh" <<'EOB'
#!/usr/bin/env sh
echo "Hello from DroidShell scripts!"
EOB
  chmod +x "$ROOT/scripts/hello.sh"

  # workspace
  cat > "$ROOT/workspace/README.txt" <<'EOB'
DroidShell workspace
--------------------
This directory is intended for user data, temporary files, and
workspace-specific artifacts created by DroidShell or its plugins.
EOB

  # packages
  cat > "$ROOT/packages/README.txt" <<'EOB'
DroidShell packages
-------------------
Reserved for future package/module distribution and installation.
EOB

  # config
  cat > "$ROOT/config/droidshell.json" <<'EOB'
{
  "version": "0.1.0",
  "defaultTheme": "default",
  "defaultShell": "/system/bin/sh",
  "allowExternalScripts": true,
  "plugin": {
    "enabled": true,
    "scanInternal": true,
    "scanPublic": true
  },
  "logging": {
    "enabled": true,
    "level": "INFO"
  }
}
EOB

  cat > "$ROOT/config/droidshell_theme.json" <<'EOB'
{
  "accent": "#00FF7F",
  "background": "#101010",
  "title": "#FFFFFF",
  "tint": "#00FF7F"
}
EOB

  cat > "$ROOT/config/droidshell_icon_map.json" <<'EOB'
{
  "bin": "ic_droidshell_bin",
  "plugins": "ic_droidshell_plugins",
  "themes": "ic_droidshell_themes",
  "scripts": "ic_droidshell_scripts",
  "workspace": "ic_droidshell_workspace",
  "packages": "ic_droidshell_packages",
  "config": "ic_droidshell_config",
  "logs": "ic_droidshell_logs"
}
EOB

  touch "$ROOT/logs/.gitkeep"

  echo "   Done: $ROOT"
  echo
}

build_root "$PUBLIC_ROOT"
build_root "$INTERNAL_ROOT"

echo "=== Generating APK resource stubs ==="

cp "$PUBLIC_ROOT/config/droidshell_theme.json" "$APK_RES_ROOT/raw/droidshell_theme.json"
cp "$PUBLIC_ROOT/config/droidshell_icon_map.json" "$APK_RES_ROOT/raw/droidshell_icon_map.json"

for icon in \
  ic_droidshell_bin \
  ic_droidshell_plugins \
  ic_droidshell_themes \
  ic_droidshell_scripts \
  ic_droidshell_workspace \
  ic_droidshell_packages \
  ic_droidshell_config \
  ic_droidshell_logs \
  ic_folder_default
do
  cat > "$APK_RES_ROOT/drawable/${icon}.xml" <<EOB
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#00FF7F"
        android:pathData="M4,4h16v16h-16z"/>
</vector>
EOB
done

echo
echo "=== DroidShell OS layer + APK resource stubs generated ==="
echo "Copy APK_Resources/drawable/* into app/src/main/res/drawable/"
echo "Copy APK_Resources/raw/* into app/src/main/res/raw/"
EOF
chmod +x build_droidshell_os.sh

###############################################
# 2) init_droidshell_project.sh
###############################################
cat > init_droidshell_project.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "=== Initializing Full DroidShell Project ==="

ROOT="$(pwd)"
APP="$ROOT/app"
APK_RES="$ROOT/APK_Resources"
OS_PUBLIC="/sdcard/DroidShell"
OS_INTERNAL="$ROOT/DroidShell_internal"

echo "-> Creating Android project structure..."

mkdir -p \
  "$APP/src/main/java/com/k1lllagt/droidshell" \
  "$APP/src/main/res/layout" \
  "$APP/src/main/res/drawable" \
  "$APP/src/main/res/raw" \
  "$APP/src/main/res/values" \
  "$APP/src/test" \
  "$APK_RES/drawable" \
  "$APK_RES/raw"

cat > "$APP/build.gradle" <<'EOG'
plugins {
    id 'com.android.application'
}

android {
    namespace "com.k1lllagt.droidshell"
    compileSdk 34

    defaultConfig {
        applicationId "com.k1lllagt.droidshell"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "0.1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
        }
    }
}

dependencies {
    implementation "androidx.core:core-ktx:1.13.1"
    implementation "androidx.appcompat:appcompat:1.7.0"
    implementation "com.google.android.material:material:1.12.0"
    implementation "androidx.recyclerview:recyclerview:1.3.2"
    implementation "androidx.constraintlayout:constraintlayout:2.2.0"
    implementation "androidx.fragment:fragment-ktx:1.8.2"
}
EOG

cat > "$ROOT/settings.gradle" <<'EOG'
rootProject.name = "DroidShell"
include(":app")
EOG

cat > "$ROOT/build.gradle" <<'EOG'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
}
EOG

echo "-> Running OS layer builder..."
chmod +x ./build_droidshell_os.sh
./build_droidshell_os.sh "$OS_PUBLIC" "$OS_INTERNAL" "$APK_RES"

echo "-> Copying APK resources into app module..."
cp -r "$APK_RES/raw/"* "$APP/src/main/res/raw/" || true
cp -r "$APK_RES/drawable/"* "$APP/src/main/res/drawable/" || true

cat > "$APP/src/main/AndroidManifest.xml" <<'EOG'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.k1lllagt.droidshell">

    <application
        android:name="com.k1lllagt.droidshell.app.DroidShellApp"
        android:allowBackup="true"
        android:theme="@style/Theme.Material3.DayNight.NoActionBar">

        <activity
            android:name="com.k1lllagt.droidshell.ui.activity.MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

    </application>
</manifest>
EOG

mkdir -p "$ROOT/.github/workflows"

cat > "$ROOT/.github/workflows/droidshell-ci.yml" <<'EOG'
name: DroidShell CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17

      - name: Make builder executable
        run: chmod +x ./build_droidshell_os.sh

      - name: Run DroidShell OS layer builder
        run: ./build_droidshell_os.sh

      - name: Copy OS resources into APK project
        run: |
          mkdir -p app/src/main/res/raw
          mkdir -p app/src/main/res/drawable
          cp -r APK_Resources/raw/* app/src/main/res/raw/ || true
          cp -r APK_Resources/drawable/* app/src/main/res/drawable/ || true

      - name: Grant execute permission for gradlew
        run: chmod +x ./gradlew

      - name: Build Debug APK
        run: ./gradlew assembleDebug --stacktrace

      - name: Upload DroidShell APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: DroidShell-debug-apk
          path: app/build/outputs/apk/debug/app-debug.apk
EOG

echo
echo "=== DroidShell Project Initialized (skeleton) ==="
echo "Next: add Java sources and layouts, then run ./gradlew assembleDebug"
EOF
chmod +x init_droidshell_project.sh

###############################################
# 3) .gitignore, README, LICENSE
###############################################
cat > .gitignore <<'EOF'
/.gradle/
/build/
/app/build/
local.properties
.DS_Store
.idea/
*.iml
APK_Resources/
DroidShell_internal/
EOF

cat > README.md <<'EOF'
# DroidShell

DroidShell is an Android-based shell environment with its own OS-like
filesystem layout, plugin system, script execution engine, and themed UI.

## Structure

- `app/` — Android application module (DroidShell.apk)
- `build_droidshell_os.sh` — Builds the DroidShell OS layer and APK resources
- `init_droidshell_project.sh` — Initializes the Android project skeleton
- `APK_Resources/` — Generated drawables and raw resources
- `DroidShell_internal/` — Internal OS layer for emulator/testing

## Quick Start

```bash
./init_droidshell_project.sh
./gradlew assembleDebug
