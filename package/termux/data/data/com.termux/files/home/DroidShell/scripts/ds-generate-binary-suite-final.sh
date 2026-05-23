#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
PKG="$ROOT/package"
STAGE="$ROOT/build/stage"

mkdir -p "$SCRIPTS" "$PKG"

# ---------------------------------------------------------------------------
# Shared staging function (local, not external)
# ---------------------------------------------------------------------------
stage_runtime_tree() {
  rm -rf "$STAGE"
  mkdir -p "$STAGE"

  rsync -av \
    --exclude ".git" \
    --exclude "package" \
    --exclude "out" \
    --exclude "site" \
    --exclude "registry/graphs" \
    --exclude "tools/electron/node_modules" \
    "$ROOT/" "$STAGE/"
}

# ---------------------------------------------------------------------------
# Termux Package Builder
# ---------------------------------------------------------------------------
cat > "$SCRIPTS/ds-build-termux-package.sh" << 'EOF_TERMUX'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
PKG="$ROOT/package/termux"
OUT="$ROOT/out"
STAGE="$ROOT/build/stage"

mkdir -p "$PKG" "$OUT"

# Stage runtime tree
rm -rf "$STAGE"
mkdir -p "$STAGE"
rsync -av \
  --exclude ".git" \
  --exclude "package" \
  --exclude "out" \
  --exclude "site" \
  --exclude "registry/graphs" \
  --exclude "tools/electron/node_modules" \
  "$ROOT/" "$STAGE/"

VERSION="$(date +%Y.%m.%d.%H%M)"
NAME="droidshell"
ARCH="all"

rm -rf "$PKG"
mkdir -p "$PKG/DEBIAN"
mkdir -p "$PKG/data/data/com.termux/files/usr/bin"
mkdir -p "$PKG/data/data/com.termux/files/home/DroidShell"

cp -r "$STAGE/"* "$PKG/data/data/com.termux/files/home/DroidShell/"

cat > "$PKG/DEBIAN/control" << EOF_CTRL
Package: $NAME
Version: $VERSION
Architecture: $ARCH
Maintainer: DroidShell
Description: DroidShell Termux package
EOF_CTRL

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

# ---------------------------------------------------------------------------
# APK Builder
# ---------------------------------------------------------------------------
cat > "$SCRIPTS/ds-build-apk.sh" << 'EOF_APK'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
PKG="$ROOT/package/apk"
OUT="$ROOT/out"
STAGE="$ROOT/build/stage"

mkdir -p "$PKG" "$OUT"

# Stage runtime tree
rm -rf "$STAGE"
mkdir -p "$STAGE"
rsync -av \
  --exclude ".git" \
  --exclude "package" \
  --exclude "out" \
  --exclude "site" \
  --exclude "registry/graphs" \
  --exclude "tools/electron/node_modules" \
  "$ROOT/" "$STAGE/"

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

echo "[APK] Built unsigned APK"
EOF_APK
chmod +x "$SCRIPTS/ds-build-apk.sh"

# ---------------------------------------------------------------------------
# AAB Builder
# ---------------------------------------------------------------------------
cat > "$SCRIPTS/ds-build-aab.sh" << 'EOF_AAB'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
PKG="$ROOT/package/aab"
OUT="$ROOT/out"
STAGE="$ROOT/build/stage"

mkdir -p "$PKG" "$OUT"

# Stage runtime tree
rm -rf "$STAGE"
mkdir -p "$STAGE"
rsync -av \
  --exclude ".git" \
  --exclude "package" \
  --exclude "out" \
  --exclude "site" \
  --exclude "registry/graphs" \
  --exclude "tools/electron/node_modules" \
  "$ROOT/" "$STAGE/"

rm -rf "$PKG"
mkdir -p "$PKG/base/assets/droidshell" "$PKG/base/manifest"

cp -r "$STAGE/"* "$PKG/base/assets/droidshell/"

cat > "$PKG/base/manifest/AndroidManifest.xml" << 'EOF_MAN2'
<manifest package="com.droidshell.app" xmlns:android="http://schemas.android.com/apk/res/android">
  <application android:label="DroidShell"/>
</manifest>
EOF_MAN2

echo "[AAB] Bundle structure ready"
echo "[AAB] Run: bundletool build-bundle --modules=base.zip --output=droidshell.aab"
EOF_AAB
chmod +x "$SCRIPTS/ds-build-aab.sh"

echo "[BINFINAL] Binary packaging suite installed and fixed."
