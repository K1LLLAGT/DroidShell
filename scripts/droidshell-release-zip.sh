#!/data/data/com.termux/files/usr/bin/bash
set -e

REL_DIR="$PWD/release-out"
TS=$(date +%Y%m%d-%H%M%S)
ZIP_NAME="DroidShell-release-$TS.zip"

mkdir -p "$REL_DIR"
TMP="$REL_DIR/release-tmp"
rm -rf "$TMP"
mkdir -p "$TMP"

echo "[DroidShell] Collecting release payload..."

# Device-side config and tools
[ -d "$HOME/.droidshell" ] && cp -a "$HOME/.droidshell" "$TMP/droidshell-config" || echo "[REL] .droidshell missing"
[ -d "$HOME/.termux" ] && cp -a "$HOME/.termux" "$TMP/termux-config" || echo "[REL] .termux missing"

# Project-side docs and scripts (if present)
[ -d docs ] && cp -a docs "$TMP/docs" || true
[ -d site ] && cp -a site "$TMP/site" || true
[ -f droidshell-tools-init.sh ] && cp droidshell-tools-init.sh "$TMP/" || true
[ -f droidshell-etc-init.sh ] && cp droidshell-etc-init.sh "$TMP/" || true
[ -f droidshell-plugin-template.sh ] && cp droidshell-plugin-template.sh "$TMP/" || true

cd "$TMP"
zip -r "../$ZIP_NAME" . >/dev/null
cd -

rm -rf "$TMP"

echo "[DroidShell] Release ZIP created: $REL_DIR/$ZIP_NAME"
