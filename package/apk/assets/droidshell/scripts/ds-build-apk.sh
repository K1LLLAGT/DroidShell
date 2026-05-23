#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/out"
PKG="$ROOT/package/apk"
STAGE="$ROOT/build/stage"

mkdir -p "$OUT" "$PKG"

# Stage runtime tree
bash "$ROOT/scripts/ds-stage.sh"

rm -rf "$PKG"
mkdir -p "$PKG/assets/droidshell"

cp -r "$STAGE/"* "$PKG/assets/droidshell/"

cat > "$PKG/AndroidManifest.xml" << 'EOF_MAN'
<manifest package="com.droidshell.app" xmlns:android="http://schemas.android.com/apk/res/android">
  <application android:label="DroidShell" android:allowBackup="false">
    <activity android:name="android.app.Activity">
      <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
      </intent-filter>
    </activity>
  </application>
</manifest>
EOF_MAN

cd "$PKG"
zip -r "$OUT/droidshell-unsigned.apk" .

echo "[APK] Built unsigned APK at $OUT/droidshell-unsigned.apk"
