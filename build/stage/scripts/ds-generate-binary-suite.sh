#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
PKG="$ROOT/package"
SCRIPTS="$ROOT/scripts"

mkdir -p "$PKG/termux" "$PKG/apk" "$PKG/aab"

echo "[BIN] Writing Termux package builder"
cat > "$SCRIPTS/ds-build-termux-package.sh" << 'EOF_TERMUX'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/out"
PKG="$ROOT/package/termux"
mkdir -p "$OUT"

VERSION="$(date +%Y.%m.%d.%H%M)"
NAME="droidshell"
ARCH="all"

mkdir -p "$PKG/DEBIAN"
cat > "$PKG/DEBIAN/control" << EOF_CTRL
Package: $NAME
Version: $VERSION
Architecture: $ARCH
Maintainer: DroidShell
Description: DroidShell Termux package
EOF_CTRL

mkdir -p "$PKG/data/data/com.termux/files/usr/bin"
mkdir -p "$PKG/data/data/com.termux/files/home/DroidShell"

cp -r "$ROOT"/* "$PKG/data/data/com.termux/files/home/DroidShell/"
cat > "$PKG/data/data/com.termux/files/usr/bin/ds" << 'EOF_LAUNCH'
#!/usr/bin/env bash
exec "$HOME/DroidShell/scripts/ds-cli.sh" "$@"
EOF_LAUNCH
chmod +x "$PKG/data/data/com.termux/files/usr/bin/ds"

DEB="$OUT/droidshell-termux-$VERSION.deb"
dpkg-deb --build "$PKG" "$DEB"

echo "[TERMUX] Built $DEB"
EOF_TERMUX
chmod +x "$SCRIPTS/ds-build-termux-package.sh"

echo "[BIN] Writing APK builder"
cat > "$SCRIPTS/ds-build-apk.sh" << 'EOF_APK'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
PKG="$ROOT/package/apk"
OUT="$ROOT/out"
mkdir -p "$OUT" "$PKG"

echo "[APK] Creating minimal Android wrapper"

mkdir -p "$PKG/assets/droidshell"
cp -r "$ROOT"/* "$PKG/assets/droidshell/"

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

echo "[APK] Building unsigned APK"
zip -r "$OUT/droidshell-unsigned.apk" "$PKG"

echo "[APK] Sign manually with apksigner if needed"
EOF_APK
chmod +x "$SCRIPTS/ds-build-apk.sh"

echo "[BIN] Writing AAB builder"
cat > "$SCRIPTS/ds-build-aab.sh" << 'EOF_AAB'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
PKG="$ROOT/package/aab"
OUT="$ROOT/out"
mkdir -p "$OUT" "$PKG"

echo "[AAB] Creating bundle structure"

mkdir -p "$PKG/base/assets/droidshell"
cp -r "$ROOT"/* "$PKG/base/assets/droidshell/"

cat > "$PKG/base/manifest/AndroidManifest.xml" << 'EOF_MAN2'
<manifest package="com.droidshell.app" xmlns:android="http://schemas.android.com/apk/res/android">
  <application android:label="DroidShell"/>
</manifest>
EOF_MAN2

echo "[AAB] Building AAB (bundletool required)"
echo "[AAB] Run: bundletool build-bundle --modules=base.zip --output=droidshell.aab"
EOF_AAB
chmod +x "$SCRIPTS/ds-build-aab.sh"

echo "[BIN] Binary packaging suite generation complete."
