#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$HOME/DroidShell"
VERSION="$(cat "$BASE_DIR/VERSION" 2>/dev/null || echo "1.0.0")"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; C='\033[1;36m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[DS]${N} $*"; }
warn() { echo -e "${Y}[!]${N}  $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

step "1/3 — Electron CVE Fix"

ELEC_DIR="$BASE_DIR/tools/electron"
ELEC_PKG="$ELEC_DIR/package.json"
mkdir -p "$ELEC_DIR"

if [[ ! -f "$ELEC_PKG" ]]; then
  cat > "$ELEC_PKG" << 'PKG'
{
  "name": "droidshell-electron-tools",
  "version": "1.0.0",
  "devDependencies": { "electron": "^41.0.0" },
  "engines": { "node": ">=22" }
}
PKG
else
  if command -v node >/dev/null 2>&1; then
    node - << NODE
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync("$ELEC_PKG", "utf8"));
pkg.devDependencies = pkg.devDependencies || {};
pkg.devDependencies.electron = "^41.0.0";
fs.writeFileSync("$ELEC_PKG", JSON.stringify(pkg, null, 2) + "\n");
NODE
  else
    sed -i 's/"electron": *"[^"]*"/"electron": "^41.0.0"/' "$ELEC_PKG"
  fi
fi

[[ ! -f "$ELEC_DIR/main.js" ]] && cat > "$ELEC_DIR/main.js" << 'MAIN'
const { app, BrowserWindow } = require('electron');
const path = require('path');
function createWindow() {
  const win = new BrowserWindow({
    width: 1024, height: 768,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });
  win.loadFile('index.html');
}
app.whenReady().then(createWindow);
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
MAIN

[[ ! -f "$ELEC_DIR/preload.js" ]] && cat > "$ELEC_DIR/preload.js" << 'PRE'
const { contextBridge } = require('electron');
contextBridge.exposeInMainWorld('droidshell', {
  version: () => process.env.npm_package_version || '1.0.0'
});
PRE

cat > "$ELEC_DIR/.npmrc" << 'NPM'
engine-strict=true
save-exact=false
NPM

step "2/3 — Write README.md"

cat > "$BASE_DIR/README.md" << 'README'
# 🛡️ DroidShell
A deterministic, modular Android terminal environment with OTA, plugins, root modules, and a hardened Electron companion.
README

step "3/3 — GitHub Release"

if command -v gh >/dev/null 2>&1 && gh auth status &>/dev/null; then
  ASSETS=()
  for f in out/droidshell-root.zip out/droidshell-nonroot.zip out/OTA.SHA256; do
    [[ -f "$BASE_DIR/$f" ]] && ASSETS+=("$BASE_DIR/$f")
  done
  gh release create "v$VERSION" "${ASSETS[@]}" \
    --title "DroidShell v$VERSION" \
    --notes "Automated release"
else
  warn "gh not available or not authenticated — skipping release"
fi

cd "$BASE_DIR"
git add tools/electron/ README.md || true
git diff --cached --quiet || { git commit -m "fix-all-three"; git push; }

echo -e "${C}Fix-All-Three complete${N}"
