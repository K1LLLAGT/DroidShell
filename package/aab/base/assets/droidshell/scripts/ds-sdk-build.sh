#!/data/data/com.termux/files/usr/bin/bash
set -e

OUT_DIR="$PWD/sdk-out"
SDK_NAME="DS-SDK-$(date +%Y%m%d).zip"

mkdir -p "$OUT_DIR"
TMP="$OUT_DIR/sdk-tmp"
rm -rf "$TMP"
mkdir -p "$TMP"

echo "[DroidShell] Assembling SDK bundle..."

# Copy SDK pieces if they exist
[ -d plugin-sdk ] && cp -a plugin-sdk "$TMP/" || echo "[SDK] plugin-sdk missing (ok if not created yet)"
[ -d plugin-template ] && cp -a plugin-template "$TMP/" || echo "[SDK] plugin-template missing"
[ -d docs ] && cp -a docs "$TMP/" || echo "[SDK] docs missing"

cat > "$TMP/README.md" << 'EOREAD'
# DroidShell SDK Bundle

Includes:
- plugin-sdk/        : core interfaces and examples
- plugin-template/   : ready-to-build plugin skeleton
- docs/              : documentation
EOREAD

cd "$TMP"
zip -r "../$SDK_NAME" . >/dev/null
cd -

rm -rf "$TMP"

echo "[DroidShell] SDK bundle created: $OUT_DIR/$SDK_NAME"
