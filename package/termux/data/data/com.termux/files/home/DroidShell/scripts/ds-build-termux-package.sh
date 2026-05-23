#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
OUT="$ROOT/out"
PKG="$ROOT/package/termux"
STAGE="$ROOT/build/stage"

mkdir -p "$OUT" "$PKG"

# Stage runtime tree
bash "$ROOT/scripts/ds-stage.sh"

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
