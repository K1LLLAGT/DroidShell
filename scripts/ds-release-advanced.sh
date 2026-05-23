#!/usr/bin/env bash
# ds-release-advanced.sh
# GitHub Releases automation + OTA server + dashboard + nightly builds +
# Magisk auto-update JSON + package registry.

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SCRIPT_DIR="$BASE_DIR/scripts"
OUT_DIR="$BASE_DIR/out"
GITHUB_DIR="$BASE_DIR/.github/workflows"
WEB_DIR="$BASE_DIR/web"
WEB_INSTALLER_DIR="$WEB_DIR/installer"
WEB_DASHBOARD_DIR="$WEB_DIR/dashboard"
OTA_DIR="$BASE_DIR/ota"
PKG_REG_DIR="$BASE_DIR/registry"
VERSION_FILE="$BASE_DIR/VERSION"
META_FILE="$OTA_DIR/metadata.json"

mkdir -p "$SCRIPT_DIR" "$OUT_DIR" "$GITHUB_DIR" "$WEB_INSTALLER_DIR" "$WEB_DASHBOARD_DIR" "$OTA_DIR" "$PKG_REG_DIR"

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  DroidShell Advanced Release System"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

############################################
# 1) GitHub Releases automation workflow
############################################
cat << 'EOF_REL' > "$GITHUB_DIR/droidshell-release.yml"
name: DroidShell Release

on:
  workflow_dispatch:
    inputs:
      channel:
        description: "Release channel (stable/beta/dev)"
        required: true
        default: "stable"
      bump:
        description: "Version bump (none/patch/minor/major)"
        required: true
        default: "patch"

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Bump version
        run: |
          chmod +x scripts/ds-version.sh || true
          case "${{ github.event.inputs.bump }}" in
            major|minor|patch)
              ./scripts/ds-version.sh "${{ github.event.inputs.bump }}"
              ;;
            none)
              echo "No bump requested."
              ;;
          esac
          echo "VERSION=$(cat VERSION)" >> $GITHUB_ENV

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

      - name: Sign packages
        run: |
          if [ -x scripts/ds-sign-packages.sh ]; then
            ./scripts/ds-sign-packages.sh
          fi

      - name: Update OTA metadata
        run: |
          if [ -x scripts/ds-ota-metadata.sh ]; then
            ./scripts/ds-ota-metadata.sh
          fi

      - name: Generate changelog
        run: |
          git log -10 --pretty=format:'- %s' > CHANGELOG.md

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: "v${{ env.VERSION }}-${{ github.event.inputs.channel }}"
          name: "DroidShell v${{ env.VERSION }} [${{ github.event.inputs.channel }}]"
          body_path: CHANGELOG.md
          files: |
            out/droidshell-root.zip
            out/droidshell-nonroot.zip
            out/droidshell-magisk-*.zip
            ota/metadata.json
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOF_REL

echo "[GEN] GitHub Releases workflow"

############################################
# 2) OTA update server (static JSON + packages)
############################################
cat << 'EOF_OTA_IDX' > "$OTA_DIR/index.json"
{
  "name": "DroidShell OTA",
  "description": "Static OTA index for DroidShell.",
  "metadata": "metadata.json"
}
EOF_OTA_IDX

echo "[GEN] OTA index.json"

############################################
# 3) Release dashboard (web UI)
############################################
cat << 'EOF_DASH' > "$WEB_DASHBOARD_DIR/index.html"
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>DroidShell Release Dashboard</title>
  <style>
    body { font-family: sans-serif; padding: 1rem; background: #111; color: #eee; }
    pre { background: #222; padding: 1rem; overflow-x: auto; }
    .card { border: 1px solid #444; padding: 1rem; margin-bottom: 1rem; border-radius: 4px; }
    h1, h2 { color: #6cf; }
  </style>
</head>
<body>
  <h1>DroidShell Release Dashboard</h1>
  <div class="card">
    <h2>OTA Metadata</h2>
    <pre id="meta">Loading...</pre>
  </div>
  <script>
    fetch('../../ota/metadata.json')
      .then(r => r.json())
      .then(j => { document.getElementById('meta').textContent = JSON.stringify(j, null, 2); })
      .catch(e => { document.getElementById('meta').textContent = 'Error: ' + e; });
  </script>
</body>
</html>
EOF_DASH

echo "[GEN] Release dashboard"

############################################
# 4) Nightly builds + changelog generator
############################################
cat << 'EOF_NIGHTLY' > "$GITHUB_DIR/droidshell-nightly.yml"
name: DroidShell Nightly

on:
  schedule:
    - cron: "0 3 * * *"
  workflow_dispatch:

jobs:
  nightly:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set nightly suffix
        run: echo "NIGHTLY_SUFFIX=$(date +%Y%m%d)" >> $GITHUB_ENV

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

      - name: Generate nightly changelog
        run: git log -5 --pretty=format:'- %s' > CHANGELOG-nightly.md

      - uses: actions/upload-artifact@v4
        with:
          name: droidshell-nightly-${{ env.NIGHTLY_SUFFIX }}
          path: |
            out/
            magisk-droidshell/
            CHANGELOG-nightly.md
EOF_NIGHTLY

echo "[GEN] Nightly workflow"

############################################
# 5) Magisk module auto-update integration
############################################
cat << 'EOF_MAGISK' > "$OTA_DIR/magisk-update.json"
{
  "version": "1.0.0",
  "versionCode": 1,
  "zipUrl": "https://github.com/K1LLLAGT/DroidShell/releases/latest/download/droidshell-magisk-1.0.0.zip",
  "changelog": "https://github.com/K1LLLAGT/DroidShell/releases/latest"
}
EOF_MAGISK

echo "[GEN] Magisk update JSON"

cat << 'EOF_MAGISK_SYNC' > "$SCRIPT_DIR/ds-magisk-update-sync.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$BASE_DIR/VERSION"
OTA_DIR="$BASE_DIR/ota"
MAGISK_JSON="$OTA_DIR/magisk-update.json"

version="$(cat "$VERSION_FILE")"

cat > "$MAGISK_JSON" <<EOF
{
  "version": "$version",
  "versionCode": 1,
  "zipUrl": "https://github.com/K1LLLAGT/DroidShell/releases/download/v$version-stable/droidshell-magisk-$version.zip",
  "changelog": "https://github.com/K1LLLAGT/DroidShell/releases/tag/v$version-stable"
}
EOF

echo "[+] Updated Magisk update JSON"
EOF_MAGISK_SYNC
chmod +x "$SCRIPT_DIR/ds-magisk-update-sync.sh"

echo "[GEN] ds-magisk-update-sync.sh"

############################################
# 6) DroidShell package registry
############################################
cat << 'EOF_REG' > "$PKG_REG_DIR/index.json"
{
  "name": "DroidShell Package Registry",
  "description": "Modules, plugins, overlays, and tools.",
  "packages": []
}
EOF_REG

echo "[GEN] Package registry index"

cat << 'EOF_REG_HELPER' > "$SCRIPT_DIR/ds-reg-add.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REG_DIR="$BASE_DIR/registry"
INDEX="$REG_DIR/index.json"

NAME="${1:-}"
FILE="${2:-}"

if [ -z "$NAME" ] || [ -z "$FILE" ]; then
  echo "Usage: $0 <name> <file>"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "[!] File not found: $FILE"
  exit 1
fi

mkdir -p "$REG_DIR/packages"
pkg="$(basename "$FILE")"
cp "$FILE" "$REG_DIR/packages/$pkg"

tmp="$INDEX.tmp"
jq ".packages += [{\"name\":\"$NAME\",\"file\":\"packages/$pkg\"}]" "$INDEX" > "$tmp"
mv "$tmp" "$INDEX"

echo "[+] Added package '$NAME'"
EOF_REG_HELPER
chmod +x "$SCRIPT_DIR/ds-reg-add.sh"

echo "[GEN] ds-reg-add.sh"

############################################
# SUMMARY
############################################
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Advanced Release System — READY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GitHub Releases workflow:  $GITHUB_DIR/droidshell-release.yml"
echo " Nightly workflow:          $GITHUB_DIR/droidshell-nightly.yml"
echo " OTA index:                 $OTA_DIR/index.json"
echo " Magisk update JSON:        $OTA_DIR/magisk-update.json"
echo " Release dashboard:         $WEB_DASHBOARD_DIR/index.html"
echo " Package registry:          $PKG_REG_DIR/index.json"
echo " Registry helper:           $SCRIPT_DIR/ds-reg-add.sh"
echo " Magisk update sync:        $SCRIPT_DIR/ds-magisk-update-sync.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
