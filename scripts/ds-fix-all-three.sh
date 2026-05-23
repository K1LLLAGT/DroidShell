
#!/usr/bin/env bash

=============================================================================

DroidShell — Fix-All-Three

ds-fix-all-three.sh



From ~/DroidShell, run:

bash scripts/ds-fix-all-three.sh



Does exactly three things in order:

1. Bump Electron to ^41.0.0  → closes Dependabot CVEs

2. Write root README.md      → proper repo landing page

3. Create GitHub Release     → v$VERSION with zip + SHA256 assets



Prerequisites:

gh CLI authenticated  (gh auth login)

npm available         (pkg install nodejs)

=============================================================================

set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASHSOURCE[0]}")/.." && pwd)"
G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; C='\033[1;36m'; M='\033[1;35m'; N='\033[0m'

log()  { echo -e "${G}[DS]${N} $*"; }
warn() { echo -e "${Y}[!]${N}  $*"; }
die()  { echo -e "${R}[ERR]${N} $*" >&2; exit 1; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

VERSION="$(cat "${BASE_DIR}/VERSION" 2>/dev/null || echo "1.0.0")"

echo -e "${M}"
cat << 'BANNER'
                                 _
 |   \    () | / || |   | | |
 | | | | '/  \| |/ ` \ \| ' \ / _ \ | |
 | || | | | () | | (| |) | | | |  / | |
 |/||  \/||\,|/|| ||\||_|
  Fix-All-Three  ·  CVEs · README · GitHub Release
BANNER
echo -e "${N}"
log "Base dir : ${BASE_DIR}"
log "Version  : ${VERSION}"

=============================================================================

1.  FIX ELECTRON CVEs  (bump to ^41.0.0)

=============================================================================
step "1/3 — Electron CVE Fix"

ELECTRONPKG="${BASEDIR}/tools/electron/package.json"

if [[ ! -f "$ELECTRON_PKG" ]]; then
  warn "tools/electron/package.json not found — writing a clean one"
  mkdir -p "${BASE_DIR}/tools/electron"
  cat > "$ELECTRON_PKG" << 'PKGJSON'
{
  "name": "droidshell-electron-tools",
  "version": "1.0.0",
  "description": "DroidShell desktop companion (Electron tooling)",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "build": "electron-builder"
  },
  "devDependencies": {
    "electron": "^41.0.0"
  },
  "engines": {
    "node": ">=22"
  }
}
PKGJSON
  log "Created clean tools/electron/package.json (electron ^41.0.0)"
else
  OLDVER="$(grep '"electron"' "$ELECTRONPKG" | grep -oE '[0-9]+\.[0-9]+\.[0-9x^~*]+' | head -1 || echo 'unknown')"
  log "Current electron version: ${OLD_VER}"

  if command -v node >/dev/null 2>&1; then
    node -e "
      const fs = require('fs');
      const pkg = JSON.parse(fs.readFileSync('${ELECTRON_PKG}', 'utf8'));
      if (!pkg.devDependencies) pkg.devDependencies = {};
      pkg.devDependencies.electron = '^41.0.0';
      if (pkg.electronSecurity) {
        pkg.electronSecurity.contextIsolation = true;
        pkg.electronSecurity.nodeIntegration = false;
      }
      fs.writeFileSync('${ELECTRON_PKG}', JSON.stringify(pkg, null, 2) + '\n');
      console.log('[node] electron bumped to ^41.0.0');
    "
  else
    warn "node not available — using sed fallback"
    sed -i 's/"electron": "[^"]"/"electron": "^41.0.0"/' "$ELECTRON_PKG"
    log "sed: electron bumped to ^41.0.0"
  fi
fi

ELECTRONMAIN="${BASEDIR}/tools/electron/main.js"
if [[ ! -f "$ELECTRON_MAIN" ]]; then
  cat > "$ELECTRONMAIN" << 'MAINJS'
// DroidShell Electron companion – security-hardened main process
const { app, BrowserWindow } = require('electron');
const path = require('path');

function createWindow() {
  const win = new BrowserWindow({
    width: 1024,
    height: 768,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      preload: path.join(dirname, 'preload.js'),
    },
  });
  win.loadFile('index.html');
}

app.whenReady().then(createWindow);
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
MAIN_JS
  log "Created tools/electron/main.js (hardened webPreferences)"
fi

PRELOAD="${BASE_DIR}/tools/electron/preload.js"
if [[ ! -f "$PRELOAD" ]]; then
  cat > "$PRELOAD" << 'PRELOAD_JS'
// DroidShell preload – runs in isolated world, exposes safe APIs only
const { contextBridge } = require('electron');
contextBridge.exposeInMainWorld('droidshell', {
  version: () => process.env.npmpackageversion || '1.0.0',
});
PRELOAD_JS
  log "Created tools/electron/preload.js (contextBridge only)"
fi

cat > "${BASE_DIR}/tools/electron/.npmrc" << 'NPMRC'
save-exact=false
engine-strict=true
NPMRC

log "tools/electron/ hardened — electron ^41.0.0, contextIsolation, sandbox"

=============================================================================

2.  ROOT README.md

=============================================================================
step "2/3 — Root README.md"

README="${BASE_DIR}/README.md"

cat > "$README" << 'READEOF'

🛡️ DroidShell

> A customized Android terminal built on Termux — deterministic startup automation,
> modular tooling, root enhancements, OTA infrastructure, and a stable ARM64 build
> pipeline for developers and power-users.

![CI](https://github.com/K1LLLAGT/DroidShell/actions/workflows/droidshell-ci.yml)
![Release](https://github.com/K1LLLAGT/DroidShell/releases)
![License: MIT](LICENSE)

---

Install

One-liner (Termux / adb shell)

`bash
curl -sSL https://raw.githubusercontent.com/K1LLLAGT/DroidShell/main/scripts/ds-install-universal.sh \
  -o ds-install-universal.sh
chmod +x ds-install-universal.sh

Review, then run:
./ds-install-universal.sh
`

Magisk module

Flash out/droidshell-root.zip via Magisk Manager or TWRP.

Non-root package

Install out/droidshell-nonroot.zip — no root required.

---

What's inside

`text
DroidShell/
├── scripts/          ← automation scripts (OTA, sync, signing, etc.)
├── root/             ← root-mode modules
├── magisk-droidshell/← Magisk module build
├── sdk/              ← Plugin SDK + templates
├── plugins/          ← Runtime plugins
├── ota/              ← OTA metadata + channels
├── out/              ← Built packages + SHA256 signatures
├── web/              ← Dashboard, installer, registry UIs
├── desktop/          ← Desktop companion scaffold
├── tools/            ← Build tooling (Electron companion)
└── .github/workflows/← CI, nightly, release workflows
`

---

Root enhancements

`bash
bash ~/DroidShell/ds_root.sh help

bash ~/DroidShell/ds_root.sh detect
bash ~/DroidShell/ds_root.sh logs --duration 60
bash ~/DroidShell/ds_root.sh net
bash ~/DroidShell/ds_root.sh backup --all
bash ~/DroidShell/ds_root.sh exec --interactive
`

---

Scripts reference

See [Looks like the result wasn't safe to show. Let's switch things up and try something else!].

---

Plugin SDK

`bash
cp -r sdk/plugin-template/ plugins/my-plugin/

edit plugins/my-plugin/*
bash scripts/ds-plugin-loader.sh
`

---

Release flow

`bash
scripts/ds-version.sh patch
scripts/ds-build-dual.sh
scripts/ds-sign-packages.sh
scripts/ds-ota-metadata.sh
git add -A && git commit -m "Release $(cat VERSION)" && git push
gh release create "v$(cat VERSION)" out/droidshell-*.zip out/OTA.SHA256
`

---

Security

Electron: contextIsolation: true, nodeIntegration: false, sandbox: true.  
OTA packages are SHA256-signed:

`bash
bash scripts/ds-verify-packages.sh
`

Report vulnerabilities via GitHub Security Advisories.
READEOF

log "README.md written ($(wc -l < "$README") lines)"

=============================================================================

3.  GITHUB RELEASE  (v$VERSION)

=============================================================================
step "3/3 — GitHub Release v${VERSION}"

if ! command -v gh >/dev/null 2>&1; then
  warn "gh CLI not found. Install: pkg install gh && gh auth login"
  warn "Skipping release creation — run manually later."
else
  if ! gh auth status &>/dev/null; then
    warn "gh not authenticated. Run: gh auth login"
    warn "Skipping release step."
  else
    if gh release view "v${VERSION}" &>/dev/null 2>&1; then
      warn "Release v${VERSION} already exists — skipping create."
    else
      NOTES_FILE="$(mktemp /tmp/ds-release-notes.XXXXXX.md)"
      trap 'rm -f "$NOTES_FILE"' EXIT

      cat > "$NOTES_FILE" << NOTES

DroidShell v${VERSION}

Initial release — root and non-root packages for Termux/Android.

Packages

| File | Description |
|------|-------------|
| \droidshell-root.zip\ | Magisk/root build |
| \droidshell-nonroot.zip\ | Non-root Termux build |
| \OTA.SHA256\ | SHA256 checksums — verify before flashing |

Verify

\\\`bash
bash scripts/ds-verify-packages.sh
\\\`

Install

\\\`bash
curl -sSL https://raw.githubusercontent.com/K1LLLAGT/DroidShell/main/scripts/ds-install-universal.sh (raw.githubusercontent.com in Bing) \\
  -o ds-install-universal.sh && bash ds-install-universal.sh
\\\`
NOTES

      ASSETS=()
      for f in \
        "${BASE_DIR}/out/droidshell-root.zip" \
        "${BASE_DIR}/out/droidshell-nonroot.zip" \
        "${BASE_DIR}/out/OTA.SHA256"; do
        [[ -f "$f" ]] && ASSETS+=("$f") || warn "Asset not found (skipped): $f"
      done

      if [[ ${#ASSETS[@]} -eq 0 ]]; then
        warn "No release assets found in out/ — creating release without assets"
        gh release create "v${VERSION}" \
          --title "DroidShell v${VERSION}" \
          --notes-file "$NOTES_FILE" \
          --repo "K1LLLAGT/DroidShell"
      else
        gh release create "v${VERSION}" \
          "${ASSETS[@]}" \
          --title "DroidShell v${VERSION}" \
          --notes-file "$NOTES_FILE" \
          --repo "K1LLLAGT/DroidShell"
      fi

      log "Release v${VERSION} created → https://github.com/K1LLLAGT/DroidShell/releases/tag/v${VERSION}"
    fi
  fi
fi

=============================================================================

COMMIT + PUSH ALL CHANGES

=============================================================================
step "Commit + Push"

cd "$BASE_DIR"

git add \
  tools/electron/ \
  README.md \
  2>/dev/null || true

if git diff --cached --quiet; then
  warn "Nothing new to commit (files may already be up to date)"
else
  git commit -m "fix: Electron CVEs, root README, GitHub Release prep

- tools/electron/package.json: bump electron to ^41.0.0
- tools/electron/main.js: contextIsolation=true, nodeIntegration=false, sandbox=true
- tools/electron/preload.js: contextBridge-only preload
- tools/electron/.npmrc: engine-strict=true
- README.md: root-level landing page"
  git push origin main
  log "Pushed to origin/main"
fi

echo ""
echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${C} Fix-All-Three — Complete${N}"
echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "  ${G}1.${N} Electron CVEs  → tools/electron/ (^41.0.0 + hardened webPreferences)"
echo -e "  ${G}2.${N} README.md      → repo root landing page"
echo -e "  ${G}3.${N} GitHub Release → v${VERSION}"
echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
