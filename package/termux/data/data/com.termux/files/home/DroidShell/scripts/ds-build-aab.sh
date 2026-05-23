#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/out"
PKG="$ROOT/package/aab"
STAGE="$ROOT/build/stage"

mkdir -p "$OUT" "$PKG"

# Stage runtime tree
bash "$ROOT/scripts/ds-stage.sh"

rm -rf "$PKG"
mkdir -p "$PKG/base/assets/droidshell" "$PKG/base/manifest"

cp -r "$STAGE/"* "$PKG/base/assets/droidshell/"

cat > "$PKG/base/manifest/AndroidManifest.xml" << 'EOF_MAN2'
<manifest package="com.droidshell.app" xmlns:android="http://schemas.android.com/apk/res/android">
  <application android:label="DroidShell"/>
</manifest>
EOF_MAN2

echo "[AAB] Bundle structure ready in $PKG"
echo "[AAB] Next: bundletool build-bundle --modules=base.zip --output=droidshell.aab"
