#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Fix Suite Generator
#  Creates:
#    - ds-fix-all-three.sh
#    - ds-fix-all-four.sh
#    - ds-fix-everything.sh
# =============================================================================

set -euo pipefail

BASE_DIR="$HOME/DroidShell"
SCRIPT_DIR="$BASE_DIR/scripts"

mkdir -p "$SCRIPT_DIR"

G='\033[1;32m'; M='\033[1;35m'; Y='\033[1;33m'; N='\033[0m'
log()  { echo -e "${G}[GEN]${N} $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

# =============================================================================
step "Writing ds-fix-all-three.sh"
# =============================================================================
cat > "$SCRIPT_DIR/ds-fix-all-three.sh" << 'EOF_THREE'
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
EOF_THREE

chmod +x "$SCRIPT_DIR/ds-fix-all-three.sh"
log "Created ds-fix-all-three.sh"

# =============================================================================
step "Writing ds-fix-all-four.sh"
# =============================================================================
cat > "$SCRIPT_DIR/ds-fix-all-four.sh" << 'EOF_FOUR'
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$HOME/DroidShell"

G='\033[1;32m'; Y='\033[1;33m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[DS]${N} $*"; }
warn() { echo -e "${Y}[!]${N}  $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

cd "$BASE_DIR"

step "1/2 — Rebuild OTA metadata"
[[ -x scripts/ds-ota-metadata.sh ]] && scripts/ds-ota-metadata.sh || warn "OTA metadata script missing"

step "2/2 — Run ds-fix-all-three.sh"
[[ -x scripts/ds-fix-all-three.sh ]] && scripts/ds-fix-all-three.sh || { warn "ds-fix-all-three missing"; exit 1; }

echo -e "${M}Fix-All-Four complete${N}"
EOF_FOUR

chmod +x "$SCRIPT_DIR/ds-fix-all-four.sh"
log "Created ds-fix-all-four.sh"

# =============================================================================
step "Writing ds-fix-everything.sh"
# =============================================================================
cat > "$SCRIPT_DIR/ds-fix-everything.sh" << 'EOF_EVERY'
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$HOME/DroidShell"

G='\033[1;32m'; Y='\033[1;33m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[DS]${N} $*"; }
warn() { echo -e "${Y}[!]${N}  $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

cd "$BASE_DIR"

run_if_present() {
  local label="$1"
  local script="$2"
  step "$label"
  [[ -x "$script" ]] && "$script" || warn "Skipping: $script"
}

run_if_present "1/5 — Ecosystem core"        "$BASE_DIR/scripts/ds-ecosystem.sh"
run_if_present "2/5 — Ecosystem bundle"      "$BASE_DIR/scripts/ds-bundle-ecosystem.sh"
run_if_present "3/5 — Services bundle"       "$BASE_DIR/scripts/ds-bundle-services.sh"
run_if_present "4/5 — Runtime bundle"        "$BASE_DIR/scripts/ds-bundle-runtime.sh"
run_if_present "5/5 — Fix-All-Four"          "$BASE_DIR/scripts/ds-fix-all-four.sh"

echo -e "${M}Fix-Everything complete${N}"
EOF_EVERY

chmod +x "$SCRIPT_DIR/ds-fix-everything.sh"
log "Created ds-fix-everything.sh"

echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} Fix Suite Generator — COMPLETE${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
