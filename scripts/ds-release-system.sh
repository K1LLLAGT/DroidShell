#!/usr/bin/env bash
# ds-release-system.sh
# Complete release system generator for DroidShell:
# - Versioning
# - GitHub Actions CI
# - Web installer
# - OTA metadata
# - Release channels
# - Signing + verification
# - Delta updates

set -euo pipefail

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  DroidShell Release System Generator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Resolve absolute base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SCRIPT_DIR="$BASE_DIR/scripts"
OUT_DIR="$BASE_DIR/out"
GITHUB_DIR="$BASE_DIR/.github/workflows"
WEB_DIR="$BASE_DIR/web/installer"
OTA_DIR="$BASE_DIR/ota"
CHANNEL_DIR="$OTA_DIR/channels"
VERSION_FILE="$BASE_DIR/VERSION"
META_FILE="$OTA_DIR/metadata.json"

# Ensure directories exist
mkdir -p "$SCRIPT_DIR" "$OUT_DIR" "$GITHUB_DIR" "$WEB_DIR" "$OTA_DIR" "$CHANNEL_DIR"

############################################
# 1) VERSIONING SYSTEM
############################################
if [ ! -f "$VERSION_FILE" ]; then
  echo "1.0.0" > "$VERSION_FILE"
  echo "[GEN] VERSION → $VERSION_FILE"
else
  echo "[SKIP] VERSION already exists"
fi

cat << 'EOF_VER' > "$SCRIPT_DIR/ds-version.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$BASE_DIR/VERSION"

cmd="${1:-show}"

read_version() {
  [ -f "$VERSION_FILE" ] && cat "$VERSION_FILE" || echo "0.0.0"
}

write_version() {
  echo "$1" > "$VERSION_FILE"
}

bump() {
  cur="$(read_version)"
  IFS='.' read -r MAJ MIN PAT <<< "$cur"
  case "$1" in
    major) MAJ=$((MAJ+1)); MIN=0; PAT=0 ;;
    minor) MIN=$((MIN+1)); PAT=0 ;;
    patch) PAT=$((PAT+1)) ;;
  esac
  echo "$MAJ.$MIN.$PAT"
}

case "$cmd" in
  show) read_version ;;
  major) write_version "$(bump major)" ;;
  minor) write_version "$(bump minor)" ;;
  patch) write_version "$(bump patch)" ;;
  *)
    echo "Usage: $0 {show|major|minor|patch}"
    exit 1
    ;;
esac
EOF_VER
chmod +x "$SCRIPT_DIR/ds-version.sh"
echo "[GEN] ds-version.sh"

############################################
# 2) GITHUB ACTIONS CI
############################################
cat << 'EOF_CI' > "$GITHUB_DIR/droidshell-ci.yml"
name: DroidShell CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Show version
        run: echo "VERSION=$(cat VERSION)" >> $GITHUB_ENV

      - name: Build dual packages
        run: |
          if [ -x scripts/ds-build-dual.sh ]; then
            ./scripts/ds-build-dual.sh
          fi

      - name: Build Magisk module
        run: |
          if [ -x scripts/build-magisk-droidshell.sh ]; then
            ./scripts/build-magisk-droidshell.sh
          fi

      - uses: actions/upload-artifact@v4
        with:
          name: droidshell-artifacts-${{ env.VERSION }}
          path: |
            out/
            magisk-droidshell/
EOF_CI
echo "[GEN] GitHub CI workflow"

############################################
# 3) WEB INSTALLER
############################################
cat << 'EOF_HTML' > "$WEB_DIR/index.html"
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>DroidShell Installer</title>
</head>
<body>
  <h1>DroidShell Installer</h1>
  <p>Run this on your device:</p>
  <pre>
curl -sSL https://raw.githubusercontent.com/K1LLLAGT/DroidShell/main/scripts/ds-install-universal.sh -o ds-install-universal.sh
chmod +x ds-install-universal.sh
./ds-install-universal.sh
  </pre>
</body>
</html>
EOF_HTML
echo "[GEN] Web installer HTML"

cat << 'EOF_WEB' > "$WEB_DIR/install.sh"
#!/usr/bin/env bash
set -euo pipefail

REPO="K1LLLAGT/DroidShell"
BRANCH="${1:-main}"

curl -sSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/ds-install-universal.sh" -o ds-install-universal.sh
chmod +x ds-install-universal.sh

echo "[+] Downloaded ds-install-universal.sh"
echo "[i] Review it, then run:"
echo "    ./ds-install-universal.sh"
EOF_WEB
chmod +x "$WEB_DIR/install.sh"
echo "[GEN] Web installer script"

############################################
# 4) OTA METADATA SYSTEM
############################################
if [ ! -f "$META_FILE" ]; then
cat << 'EOF_META' > "$META_FILE"
{
  "version": "1.0.0",
  "channels": {
    "stable": {
      "root": "out/droidshell-root.zip",
      "nonroot": "out/droidshell-nonroot.zip"
    },
    "beta": { "root": "", "nonroot": "" },
    "dev": { "root": "", "nonroot": "" }
  },
  "signatures": {
    "root": "",
    "nonroot": ""
  }
}
EOF_META
echo "[GEN] OTA metadata"
else
echo "[SKIP] OTA metadata exists"
fi

cat << 'EOF_OTA' > "$SCRIPT_DIR/ds-ota-metadata.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
META_FILE="$BASE_DIR/ota/metadata.json"
VERSION_FILE="$BASE_DIR/VERSION"
OUT_DIR="$BASE_DIR/out"

version="$(cat "$VERSION_FILE")"

root_pkg="$OUT_DIR/droidshell-root.zip"
nonroot_pkg="$OUT_DIR/droidshell-nonroot.zip"

root_sig=""
nonroot_sig=""

if command -v sha256sum >/dev/null 2>&1; then
  [ -f "$root_pkg" ] && root_sig="$(sha256sum "$root_pkg" | awk '{print $1}')"
  [ -f "$nonroot_pkg" ] && nonroot_sig="$(sha256sum "$nonroot_pkg" | awk '{print $1}')"
fi

cat > "$META_FILE" <<EOF
{
  "version": "$version",
  "channels": {
    "stable": {
      "root": "out/droidshell-root.zip",
      "nonroot": "out/droidshell-nonroot.zip"
    },
    "beta": { "root": "", "nonroot": "" },
    "dev": { "root": "", "nonroot": "" }
  },
  "signatures": {
    "root": "$root_sig",
    "nonroot": "$nonroot_sig"
  }
}
EOF

echo "[+] Updated OTA metadata"
EOF_OTA
chmod +x "$SCRIPT_DIR/ds-ota-metadata.sh"
echo "[GEN] ds-ota-metadata.sh"

############################################
# 5) RELEASE CHANNELS
############################################
cat << 'EOF_ST' > "$CHANNEL_DIR/stable.json"
{ "name": "stable", "description": "Stable, tested releases.", "default": true }
EOF_ST

cat << 'EOF_BT' > "$CHANNEL_DIR/beta.json"
{ "name": "beta", "description": "Pre-release builds.", "default": false }
EOF_BT

cat << 'EOF_DV' > "$CHANNEL_DIR/dev.json"
{ "name": "dev", "description": "Development snapshots.", "default": false }
EOF_DV

echo "[GEN] Release channels"

############################################
# 6) SIGNING + VERIFICATION
############################################
cat << 'EOF_SIGN' > "$SCRIPT_DIR/ds-sign-packages.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$BASE_DIR/out"
SIG_FILE="$OUT_DIR/OTA.SHA256"

> "$SIG_FILE"

cd "$OUT_DIR"
for f in droidshell-*.zip; do
  [ -f "$f" ] || continue
  sha256sum "$f" >> "$SIG_FILE"
done

echo "[+] Wrote signatures to $SIG_FILE"
EOF_SIGN
chmod +x "$SCRIPT_DIR/ds-sign-packages.sh"
echo "[GEN] ds-sign-packages.sh"

cat << 'EOF_VERIFY' > "$SCRIPT_DIR/ds-verify-packages.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$BASE_DIR/out"
SIG_FILE="$OUT_DIR/OTA.SHA256"

cd "$OUT_DIR"
sha256sum -c "$SIG_FILE"
EOF_VERIFY
chmod +x "$SCRIPT_DIR/ds-verify-packages.sh"
echo "[GEN] ds-verify-packages.sh"

############################################
# 7) DELTA UPDATES
############################################
cat << 'EOF_DELTA' > "$SCRIPT_DIR/ds-delta-root-modules.sh"
#!/usr/bin/env bash
set -euo pipefail

OLD_DIR="${1:-}"
NEW_DIR="${2:-}"
OUT_ARCHIVE="${3:-delta-root-modules.tar.gz}"

if [ -z "$OLD_DIR" ] || [ -z "$NEW_DIR" ]; then
  echo "Usage: $0 <old> <new> [out]"
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cd "$NEW_DIR/root/modules"

for f in *.sh; do
  [ -f "$f" ] || continue
  if [ ! -f "$OLD_DIR/root/modules/$f" ] || ! cmp -s "$f" "$OLD_DIR/root/modules/$f"; then
    cp "$f" "$TMP/$f"
  fi
done

cd "$TMP"
tar -czf "$OUT_ARCHIVE" .
echo "[+] Delta archive created: $OUT_ARCHIVE"
EOF_DELTA
chmod +x "$SCRIPT_DIR/ds-delta-root-modules.sh"
echo "[GEN] ds-delta-root-modules.sh"

############################################
# SUMMARY
############################################
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Release System — READY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Version file:        $VERSION_FILE"
echo " Version script:      $SCRIPT_DIR/ds-version.sh"
echo " CI workflow:         $GITHUB_DIR/droidshell-ci.yml"
echo " Web installer:       $WEB_DIR/index.html"
echo " OTA metadata:        $META_FILE"
echo " Channels:            $CHANNEL_DIR"
echo " Signing scripts:     $SCRIPT_DIR/ds-sign-packages.sh"
echo "                      $SCRIPT_DIR/ds-verify-packages.sh"
echo " Delta script:        $SCRIPT_DIR/ds-delta-root-modules.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
