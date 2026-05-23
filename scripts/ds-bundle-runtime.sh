#!/usr/bin/env bash
# =============================================================================
#  DroidShell Bundle Runtime Generator
#  ds-bundle-runtime.sh
#
#  From ~/DroidShell, run:
#    bash scripts/ds-bundle-runtime.sh
#
#  Generates:
#    1. Plugin loader + runtime hooks
#    2. WebSocket live log streamer
#    3. REST API spec + auto-doc generator
#    4. Cross-device sync (WebDAV / GitHub)
#    5. Module sandbox + permission model
#    6. Desktop companion scaffolding
# =============================================================================

set -euo pipefail

# ── Paths ─────────────────────────────────────────────────────────────────────
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="${BASE_DIR}/scripts"
SDK_DIR="${BASE_DIR}/sdk"
RUNTIME_DIR="${BASE_DIR}/runtime"
SYNC_DIR="${BASE_DIR}/sync"
DESKTOP_DIR="${BASE_DIR}/desktop"
LOG_DIR="${BASE_DIR}/logs"
WEB_DIR="${BASE_DIR}/web"
PLUGIN_DIR="${BASE_DIR}/plugins"

mkdir -p "$SCRIPT_DIR" "$SDK_DIR" "$RUNTIME_DIR" "$SYNC_DIR" \
         "$DESKTOP_DIR" "$LOG_DIR" "$WEB_DIR" "$PLUGIN_DIR"

# ── Colour helpers ────────────────────────────────────────────────────────────
G='\033[1;32m'; C='\033[1;36m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[GEN]${N} $*"; }
info() { echo -e "${C}[DS-Runtime]${N} $*"; }

echo -e "${M}"
cat << 'BANNER'
  ____            _     _ ____  _          _ _
 |  _ \ _ __ ___ (_) __| / ___|| |__   ___| | |
 | | | | '__/ _ \| |/ _` \___ \| '_ \ / _ \ | |
 | |_| | | | (_) | | (_| |___) | | | |  __/ | |
 |____/|_|  \___/|_|\__,_|____/|_| |_|\___|_|_|
  Bundle Runtime  ·  plugins · ws · api · sync
BANNER
echo -e "${N}"
info "Base dir: ${BASE_DIR}"

# =============================================================================
#  1.  PLUGIN LOADER + RUNTIME HOOKS
# =============================================================================
cat > "${SCRIPT_DIR}/ds-plugin-loader.sh" << 'EOF_LOADER'
#!/usr/bin/env bash
# DroidShell :: scripts/ds-plugin-loader.sh
# Scans plugins/ for manifest.json + plugin.sh and runs each in order.
# Usage: ds-plugin-loader.sh [--dry-run] [--plugin <name>]

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; C='\033[1;36m'; N='\033[0m'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="${BASE_DIR}/plugins"
DRY_RUN=false
FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --plugin)  FILTER="$2"; shift ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
  shift
done

mkdir -p "$PLUGIN_DIR"
loaded=0; skipped=0; failed=0

for plugin_dir in "${PLUGIN_DIR}"/*/; do
  [[ -d "$plugin_dir" ]] || continue
  name="$(basename "$plugin_dir")"

  [[ -n "$FILTER" && "$name" != "$FILTER" ]] && continue

  manifest="${plugin_dir}/manifest.json"
  entry="${plugin_dir}/plugin.sh"
  perms="${plugin_dir}/permissions"

  if [[ ! -f "$manifest" ]]; then
    echo -e "${Y}[SKIP]${N} ${name}: missing manifest.json"
    ((skipped++)); continue
  fi
  if [[ ! -x "$entry" ]]; then
    echo -e "${Y}[SKIP]${N} ${name}: plugin.sh missing or not executable"
    ((skipped++)); continue
  fi

  echo -e "${C}[LOAD]${N} ${name}"
  [[ -f "$perms" ]] && echo -e "  perms: $(tr '\n' ',' < "$perms" | sed 's/,$//')"

  if $DRY_RUN; then
    echo -e "  ${Y}[DRY]${N} would exec: ${entry}"
    ((loaded++)); continue
  fi

  if bash "$entry"; then
    echo -e "  ${G}[OK]${N} ${name}"
    ((loaded++))
  else
    echo -e "  ${R}[FAIL]${N} ${name} exited non-zero"
    ((failed++))
  fi
done

echo -e "\n${C}Plugin summary: ${loaded} loaded, ${skipped} skipped, ${failed} failed${N}"
[[ $failed -eq 0 ]]
EOF_LOADER
chmod +x "${SCRIPT_DIR}/ds-plugin-loader.sh"
log "ds-plugin-loader.sh"

# ── Sample plugin scaffold ────────────────────────────────────────────────────
SAMPLE_PLUGIN="${PLUGIN_DIR}/example-plugin"
mkdir -p "$SAMPLE_PLUGIN"

cat > "${SAMPLE_PLUGIN}/manifest.json" << 'EOF_MANIFEST'
{
  "name":        "example-plugin",
  "version":     "0.1.0",
  "description": "DroidShell example plugin scaffold",
  "author":      "K1LLLAGT",
  "permissions": []
}
EOF_MANIFEST

cat > "${SAMPLE_PLUGIN}/plugin.sh" << 'EOF_PLUG'
#!/usr/bin/env bash
# DroidShell example plugin
echo "[example-plugin] Hello from plugin runtime"
EOF_PLUG
chmod +x "${SAMPLE_PLUGIN}/plugin.sh"
log "plugins/example-plugin/ (scaffold)"

# =============================================================================
#  2.  WEBSOCKET LIVE LOG STREAMER
# =============================================================================
cat > "${SCRIPT_DIR}/ds-log-stream.sh" << 'EOF_WS'
#!/usr/bin/env bash
# DroidShell :: scripts/ds-log-stream.sh
# Streams a log file over a WebSocket using websocat.
# Usage: ds-log-stream.sh [port] [log-file]
#   port     default: 9090
#   log-file default: ~/DroidShell/logs/droidshell.log

set -euo pipefail
C='\033[1;36m'; Y='\033[1;33m'; N='\033[0m'

PORT="${1:-9090}"
LOG_FILE="${2:-${HOME}/DroidShell/logs/droidshell.log}"

if ! command -v websocat >/dev/null 2>&1; then
  echo -e "${Y}[!] websocat not found.${N}"
  echo "    Install: pkg install websocat"
  exit 1
fi

# Create log file if it doesn't exist yet
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

echo -e "${C}[LogStream]${N} Streaming ${LOG_FILE} → ws://0.0.0.0:${PORT}"
echo -e "${C}[LogStream]${N} Connect with:  websocat ws://127.0.0.1:${PORT}"
echo -e "${C}[LogStream]${N} Press Ctrl+C to stop."

exec tail -F "$LOG_FILE" | websocat --no-close -s "tcp-l:0.0.0.0:${PORT}"
EOF_WS
chmod +x "${SCRIPT_DIR}/ds-log-stream.sh"
log "ds-log-stream.sh"

# =============================================================================
#  3.  REST API SPEC + AUTO-DOC GENERATOR
# =============================================================================
cat > "${SCRIPT_DIR}/ds-api-docs.sh" << 'EOF_API'
#!/usr/bin/env bash
# DroidShell :: scripts/ds-api-docs.sh
# Generates web/api-docs.json (OpenAPI-like spec) from embedded definition.
# Usage: ds-api-docs.sh [--out <file>] [--html]

set -euo pipefail
G='\033[1;32m'; C='\033[1;36m'; N='\033[0m'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_JSON="${BASE_DIR}/web/api-docs.json"
GEN_HTML=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)  OUT_JSON="$2"; shift ;;
    --html) GEN_HTML=true ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
  shift
done

mkdir -p "$(dirname "$OUT_JSON")"

VERSION="1.0.0"
[[ -f "${BASE_DIR}/VERSION" ]] && VERSION="$(cat "${BASE_DIR}/VERSION")"

cat > "$OUT_JSON" << SPEC
{
  "openapi": "3.0.0",
  "info": {
    "title": "DroidShell API",
    "version": "${VERSION}",
    "description": "DroidShell device-local REST API"
  },
  "servers": [{ "url": "http://localhost:8080" }],
  "paths": {
    "/health": {
      "get": { "summary": "Health check", "responses": { "200": { "description": "OK" } } }
    },
    "/ota/metadata": {
      "get": { "summary": "OTA metadata", "responses": { "200": { "description": "OTA JSON" } } }
    },
    "/registry": {
      "get": { "summary": "Package registry", "responses": { "200": { "description": "Package list" } } }
    },
    "/plugins": {
      "get": { "summary": "List loaded plugins", "responses": { "200": { "description": "Plugin list" } } }
    },
    "/logs/stream": {
      "get": { "summary": "WebSocket log stream endpoint", "responses": { "101": { "description": "Upgrade to WS" } } }
    }
  }
}
SPEC

echo -e "${G}[✓]${N} API spec → ${OUT_JSON}"

if $GEN_HTML; then
  OUT_HTML="${OUT_JSON%.json}.html"
  cat > "$OUT_HTML" << 'HTDOC'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>DroidShell API Docs</title>
  <style>
    body { font-family: monospace; background:#0d0d0d; color:#c9d1d9; padding:20px; }
    h1   { color:#58a6ff; }
    pre  { background:#161b22; border:1px solid #30363d; border-radius:6px;
           padding:16px; overflow-x:auto; }
  </style>
</head>
<body>
  <h1>DroidShell API</h1>
  <pre id="spec">Loading…</pre>
  <script>
    fetch('api-docs.json').then(r=>r.json()).then(d=>{
      document.getElementById('spec').textContent = JSON.stringify(d,null,2);
    });
  </script>
</body>
</html>
HTDOC
  echo -e "${G}[✓]${N} HTML doc  → ${OUT_HTML}"
fi
EOF_API
chmod +x "${SCRIPT_DIR}/ds-api-docs.sh"
log "ds-api-docs.sh"

# =============================================================================
#  4.  CROSS-DEVICE SYNC (WebDAV + GitHub)
# =============================================================================
cat > "${SCRIPT_DIR}/ds-sync.sh" << 'EOF_SYNC'
#!/usr/bin/env bash
# DroidShell :: scripts/ds-sync.sh
# Cross-device sync via rclone (WebDAV/cloud) or git (GitHub).
# Usage: ds-sync.sh <command> [options]
#
# Commands:
#   webdav-push [remote]   push ~/DroidShell to rclone remote (default: remote)
#   webdav-pull [remote]   pull from rclone remote
#   github-push [msg]      commit all + push
#   github-pull            git pull
#   status                 show sync status for both backends

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; N='\033[0m'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMOTE="${DROIDSHELL_REMOTE:-remote}"

cmd="${1:-help}"; shift 2>/dev/null || true

case "$cmd" in
  webdav-push)
    REMOTE="${1:-$REMOTE}"
    command -v rclone >/dev/null 2>&1 || { echo -e "${Y}[!] rclone not found. Install: pkg install rclone${N}"; exit 1; }
    echo -e "${C}[Sync]${N} Pushing to ${REMOTE}:/DroidShell ..."
    rclone copy "${BASE_DIR}/" "${REMOTE}:/DroidShell" --progress --exclude ".git/**"
    echo -e "${G}[✓] Push complete${N}"
    ;;
  webdav-pull)
    REMOTE="${1:-$REMOTE}"
    command -v rclone >/dev/null 2>&1 || { echo -e "${Y}[!] rclone not found${N}"; exit 1; }
    echo -e "${C}[Sync]${N} Pulling from ${REMOTE}:/DroidShell ..."
    rclone copy "${REMOTE}:/DroidShell" "${BASE_DIR}/" --progress
    echo -e "${G}[✓] Pull complete${N}"
    ;;
  github-push)
    MSG="${1:-Sync $(date -Iseconds)}"
    cd "$BASE_DIR"
    git add -A
    git diff --cached --quiet && { echo "[i] Nothing to commit."; exit 0; }
    git commit -m "$MSG"
    git push
    echo -e "${G}[✓] Pushed to GitHub${N}"
    ;;
  github-pull)
    cd "$BASE_DIR"
    git pull
    echo -e "${G}[✓] Pulled from GitHub${N}"
    ;;
  status)
    echo -e "${C}── Git status ─────────────────────────────────${N}"
    cd "$BASE_DIR"
    git status --short 2>/dev/null || echo "(not a git repo)"
    echo -e "${C}── rclone remotes ─────────────────────────────${N}"
    command -v rclone >/dev/null 2>&1 && rclone listremotes || echo "(rclone not installed)"
    ;;
  help|*)
    echo "DroidShell Sync"
    echo "Usage: $(basename "$0") <command> [options]"
    echo "  webdav-push [remote]  — rclone push to remote:/DroidShell"
    echo "  webdav-pull [remote]  — rclone pull from remote:/DroidShell"
    echo "  github-push [msg]     — git commit -m msg + push"
    echo "  github-pull           — git pull"
    echo "  status                — show git + rclone status"
    echo ""
    echo "  DROIDSHELL_REMOTE env var sets default rclone remote (default: 'remote')"
    ;;
esac
EOF_SYNC
chmod +x "${SCRIPT_DIR}/ds-sync.sh"
log "ds-sync.sh"

# =============================================================================
#  5.  MODULE SANDBOX + PERMISSION MODEL
# =============================================================================
cat > "${SCRIPT_DIR}/ds-sandbox.sh" << 'EOF_SANDBOX'
#!/usr/bin/env bash
# DroidShell :: scripts/ds-sandbox.sh
# Manage plugin sandbox permissions (net / fs / exec / root).
# Usage: ds-sandbox.sh <plugin> <action>
#   Actions: allow-net  allow-fs  allow-exec  allow-root
#            revoke-net revoke-fs revoke-exec revoke-root
#            show       check <perm>

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; C='\033[1;36m'; N='\033[0m'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="${BASE_DIR}/plugins"

[[ -n "${1:-}" ]] || { echo "Usage: $(basename "$0") <plugin> <action>"; exit 1; }
PLUGIN="$1"
ACTION="${2:-show}"
PERM_FILE="${PLUGIN_DIR}/${PLUGIN}/permissions"

[[ -d "${PLUGIN_DIR}/${PLUGIN}" ]] || {
  echo -e "${R}[!] Plugin not found: ${PLUGIN}${N}"; exit 1; }

mkdir -p "$(dirname "$PERM_FILE")"
touch "$PERM_FILE"

_grant() {
  grep -qxF "$1" "$PERM_FILE" 2>/dev/null && {
    echo -e "${Y}[!] ${PLUGIN} already has ${1} permission${N}"; return; }
  echo "$1" >> "$PERM_FILE"
  echo -e "${G}[✓] Granted ${1} to ${PLUGIN}${N}"
}

_revoke() {
  grep -qxF "$1" "$PERM_FILE" 2>/dev/null || {
    echo -e "${Y}[!] ${PLUGIN} does not have ${1} permission${N}"; return; }
  sed -i "/^${1}$/d" "$PERM_FILE"
  echo -e "${G}[✓] Revoked ${1} from ${PLUGIN}${N}"
}

case "$ACTION" in
  allow-net)   _grant  "net"  ;;
  allow-fs)    _grant  "fs"   ;;
  allow-exec)  _grant  "exec" ;;
  allow-root)  _grant  "root" ;;
  revoke-net)  _revoke "net"  ;;
  revoke-fs)   _revoke "fs"   ;;
  revoke-exec) _revoke "exec" ;;
  revoke-root) _revoke "root" ;;
  show)
    echo -e "${C}Permissions for ${PLUGIN}:${N}"
    [[ -s "$PERM_FILE" ]] && cat "$PERM_FILE" || echo "  (none)"
    ;;
  check)
    PERM="${3:-}"
    [[ -n "$PERM" ]] || { echo "Usage: check <perm>"; exit 1; }
    if grep -qxF "$PERM" "$PERM_FILE" 2>/dev/null; then
      echo -e "${G}[✓] ${PLUGIN} has ${PERM}${N}"; exit 0
    else
      echo -e "${Y}[✗] ${PLUGIN} does NOT have ${PERM}${N}"; exit 1
    fi
    ;;
  *)
    echo "Unknown action: ${ACTION}"
    echo "Valid: allow-{net,fs,exec,root}  revoke-{net,fs,exec,root}  show  check <perm>"
    exit 1 ;;
esac
EOF_SANDBOX
chmod +x "${SCRIPT_DIR}/ds-sandbox.sh"
log "ds-sandbox.sh"

# =============================================================================
#  6.  DESKTOP COMPANION SCAFFOLDING
# =============================================================================
mkdir -p "${DESKTOP_DIR}/src"

cat > "${DESKTOP_DIR}/README.md" << 'EOF_DESK_README'
# DroidShell Desktop Companion

Scaffold for a future cross-platform desktop companion app.

## Suggested stacks

| Stack      | Notes                                       |
|------------|---------------------------------------------|
| Tauri      | Rust + WebView, small binary, recommended   |
| Electron   | Node + Chromium, larger but familiar        |
| Flask+WebView | Python, easiest for rapid prototyping   |

## Features (planned)

- Connect to device API server (ds-api.sh)
- Live log viewer (ws://device:9090 via ds-log-stream.sh)
- Package manager UI
- OTA update trigger + progress
- Plugin permission manager
- Cross-device sync control (ds-sync.sh)

## Quick start (Flask prototype)

```bash
pip install flask flask-cors
python src/app.py
```
EOF_DESK_README

cat > "${DESKTOP_DIR}/src/app.py" << 'EOF_FLASK'
#!/usr/bin/env python3
"""
DroidShell Desktop Companion — Flask prototype
"""
from flask import Flask, jsonify
from flask_cors import CORS
import subprocess, json, os

app = Flask(__name__)
CORS(app)

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))

def run_ds(script, *args):
    path = os.path.join(BASE_DIR, "scripts", script)
    result = subprocess.run(["bash", path, *args],
                            capture_output=True, text=True, timeout=30)
    return {"stdout": result.stdout, "stderr": result.stderr,
            "returncode": result.returncode}

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/version")
def version():
    vfile = os.path.join(BASE_DIR, "VERSION")
    ver = open(vfile).read().strip() if os.path.exists(vfile) else "unknown"
    return jsonify({"version": ver})

@app.route("/ota/metadata")
def ota_metadata():
    mfile = os.path.join(BASE_DIR, "ota", "metadata.json")
    if os.path.exists(mfile):
        return jsonify(json.load(open(mfile)))
    return jsonify({"error": "metadata not found"}), 404

@app.route("/plugins")
def plugins():
    pdir = os.path.join(BASE_DIR, "plugins")
    names = [d for d in os.listdir(pdir)
             if os.path.isdir(os.path.join(pdir, d))] if os.path.isdir(pdir) else []
    return jsonify({"plugins": names})

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)
EOF_FLASK

log "desktop/README.md"
log "desktop/src/app.py (Flask prototype)"

# =============================================================================
#  SUMMARY
# =============================================================================
echo ""
echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${C} Bundle Runtime — READY${N}"
echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
printf '  %-14s %s\n' \
  "1. Plugin:"   "${SCRIPT_DIR}/ds-plugin-loader.sh" \
  "   Sample:"   "${PLUGIN_DIR}/example-plugin/" \
  "2. LogStream:" "${SCRIPT_DIR}/ds-log-stream.sh" \
  "3. API docs:" "${SCRIPT_DIR}/ds-api-docs.sh" \
  "4. Sync:"     "${SCRIPT_DIR}/ds-sync.sh" \
  "5. Sandbox:"  "${SCRIPT_DIR}/ds-sandbox.sh" \
  "6. Desktop:"  "${DESKTOP_DIR}/"
echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"

