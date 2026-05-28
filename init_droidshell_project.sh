#!/usr/bin/env bash
set -euo pipefail

echo "=== Initializing Full DroidShell Project ==="

ROOT="$(pwd)"
APP="$ROOT/app"
APK_RES="$ROOT/APK_Resources"
OS_PUBLIC="/sdcard/DroidShell"
OS_INTERNAL="$ROOT/DroidShell_internal"

###############################################
# 1. CREATE ANDROID PROJECT STRUCTURE
###############################################
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

cat > "$APP/build.gradle" <<'EOF'
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
EOF

cat > "$ROOT/settings.gradle" <<'EOF'
rootProject.name = "DroidShell"
include(":app")
EOF

cat > "$ROOT/build.gradle" <<'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

###############################################
# 2. GENERATE OS LAYER (PUBLIC + INTERNAL)
###############################################
echo "-> Running OS layer builder..."
chmod +x ./build_droidshell_os.sh
./build_droidshell_os.sh "$OS_PUBLIC" "$OS_INTERNAL" "$APK_RES"

###############################################
# 3. COPY APK RESOURCES INTO PROJECT
###############################################
echo "-> Copying APK resources into app module..."

cp -r "$APK_RES/raw/"* "$APP/src/main/res/raw/" || true
cp -r "$APK_RES/drawable/"* "$APP/src/main/res/drawable/" || true

###############################################
# 4. CREATE MINIMAL MANIFEST
###############################################
cat > "$APP/src/main/AndroidManifest.xml" <<'EOF'
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
EOF

###############################################
# 5. CREATE BASIC VALUES FILES
###############################################
cat > "$APP/src/main/res/values/strings.xml" <<'EOF'
<resources>
    <string name="app_name">DroidShell</string>
</resources>
EOF

cat > "$APP/src/main/res/values/themes.xml" <<'EOF'
<resources xmlns:tools="http://schemas.android.com/tools">
    <style name="Theme.DroidShell" parent="Theme.Material3.DayNight.NoActionBar">
    </style>
</resources>
EOF

###############################################
# 6. CREATE GITHUB ACTIONS PIPELINE
###############################################
echo "-> Creating GitHub Actions CI pipeline..."

mkdir -p "$ROOT/.github/workflows"

cat > "$ROOT/.github/workflows/droidshell-ci.yml" <<'EOF'
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
EOF

###############################################
# DONE
###############################################
echo
echo "=== DroidShell Project Initialized Successfully ==="
echo "Open this folder in Android Studio to begin development."
