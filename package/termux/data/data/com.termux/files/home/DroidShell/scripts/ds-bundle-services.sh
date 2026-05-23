#!/usr/bin/env bash
# ds-bundle-services.sh
# Adds:
# - TUI control center
# - Local API server
# - Plugin SDK skeleton
# - Service manager
# - Web Console 2.0

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$BASE_DIR/scripts"
SDK_DIR="$BASE_DIR/sdk"
WEB_DIR="$BASE_DIR/web"
WEB_CONSOLE2_DIR="$WEB_DIR/console2"

mkdir -p "$SCRIPT_DIR" "$SDK_DIR" "$WEB_CONSOLE2_DIR"

log() { echo "[DroidShell-Services] $*"; }

log "Base dir: $BASE_DIR"

############################################
# 1) TUI control center
############################################
cat << 'EOF_TUI' > "$SCRIPT_DIR/ds-tui.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$BASE_DIR/scripts"

pause() { printf "\nPress Enter to continue..."; read -r _; }

while true; do
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " DroidShell TUI Control Center"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " 1) Check for OTA update (stable)"
  echo " 2) Run OTA client (choose channel)"
  echo " 3) List registry packages"
  echo " 4) Open Web Console (file path hint)"
  echo " 5) Start updater daemon (foreground)"
  echo " 6) Package manager (interactive)"
  echo " 7) Exit"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  printf "Select: "
  read -r choice
  case "$choice" in
    1)
      "$SCRIPTS/ds-ota-client.sh" stable || true
      pause
      ;;
    2)
      printf "Channel (stable/beta/dev): "
      read -r ch
      "$SCRIPTS/ds-ota-client.sh" "${ch:-stable}" || true
      pause
      ;;
    3)
      "$SCRIPTS/ds-pkg.sh" list || true
      pause
      ;;
    4)
      echo "Open in browser:"
      echo "  $BASE_DIR/web/console/index.html"
      echo "  $BASE_DIR/web/console2/index.html"
      pause
      ;;
    5)
      echo "Starting updater daemon (Ctrl+C to stop)..."
      "$SCRIPTS/ds-updater-daemon.sh" 60 || true
      pause
      ;;
    6)
      echo "Registry packages:"
      "$SCRIPTS/ds-pkg.sh" list || true
      printf "\nEnter package name to install (or blank to cancel): "
      read -r name
      [ -n "$name" ] && "$SCRIPTS/ds-pkg.sh" install "$name" || true
      pause
      ;;
    7)
      exit 0
      ;;
    *)
      ;;
  esac
done
EOF_TUI
chmod +x "$SCRIPT_DIR/ds-tui.sh"
log "[GEN] ds-tui.sh"

############################################
# 2) Local API server (simple HTTP JSON)
############################################
cat << 'EOF_API' > "$SCRIPT_DIR/ds-api-server.sh"
#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8080}"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OTA_DIR="$BASE_DIR/ota"
REG_DIR="$BASE_DIR/registry"

log() { echo "[DroidShell-API] $*"; }

if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
  log "Python is required for the API server."
  exit 1
fi

PYTHON_BIN="$(command -v python3 || command -v python)"

export DS_BASE_DIR="$BASE_DIR"
export DS_OTA_DIR="$OTA_DIR"
export DS_REG_DIR="$REG_DIR"

"$PYTHON_BIN" - << 'PY'
import http.server, json, os, socketserver

BASE = os.environ.get("DS_BASE_DIR", ".")
OTA = os.environ.get("DS_OTA_DIR", os.path.join(BASE, "ota"))
REG = os.environ.get("DS_REG_DIR", os.path.join(BASE, "registry"))

class Handler(http.server.BaseHTTPRequestHandler):
    def _send_json(self, obj, code=200):
        data = json.dumps(obj).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/health":
            self._send_json({"status": "ok"})
        elif self.path == "/ota/metadata":
            path = os.path.join(OTA, "metadata.json")
            if os.path.exists(path):
                with open(path, "r") as f:
                    self._send_json(json.load(f))
            else:
                self._send_json({"error": "metadata.json not found"}, 404)
        elif self.path == "/registry":
            path = os.path.join(REG, "index.json")
            if os.path.exists(path):
                with open(path, "r") as f:
                    self._send_json(json.load(f))
            else:
                self._send_json({"error": "registry index not found"}, 404)
        else:
            self._send_json({"error": "not found"}, 404)

PORT = int(os.environ.get("DS_API_PORT", "8080"))
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"[DroidShell-API] Serving on port {PORT}")
    httpd.serve_forever()
PY
EOF_API
chmod +x "$SCRIPT_DIR/ds-api-server.sh"
log "[GEN] ds-api-server.sh"

############################################
# 3) Plugin SDK skeleton
############################################
mkdir -p "$SDK_DIR/plugin-template"

cat << 'EOF_SDK_README' > "$SDK_DIR/README.md"
# DroidShell Plugin SDK

This directory contains templates and conventions for building DroidShell plugins/modules.

## Basic layout

- plugin-template/
  - plugin.sh        # entrypoint
  - manifest.json    # metadata
  - README.md        # docs

## Manifest fields

- name
- description
- version
- author
- entrypoint
EOF_SDK_README

cat << 'EOF_PLUGIN_MANIFEST' > "$SDK_DIR/plugin-template/manifest.json"
{
  "name": "ExamplePlugin",
  "description": "Example DroidShell plugin.",
  "version": "1.0.0",
  "author": "Your Name",
  "entrypoint": "plugin.sh"
}
EOF_PLUGIN_MANIFEST

cat << 'EOF_PLUGIN_SH' > "$SDK_DIR/plugin-template/plugin.sh"
#!/usr/bin/env bash
# Example DroidShell plugin entrypoint

echo "[ExamplePlugin] Hello from DroidShell plugin!"
EOF_PLUGIN_SH
chmod +x "$SDK_DIR/plugin-template/plugin.sh"

cat << 'EOF_PLUGIN_README' > "$SDK_DIR/plugin-template/README.md"
# ExamplePlugin

Example DroidShell plugin.

## Usage

Copy this directory, rename it, edit manifest.json and plugin.sh, then integrate with your registry or loader.
EOF_PLUGIN_README

log "[GEN] Plugin SDK skeleton in sdk/"

############################################
# 4) Service manager
############################################
cat << 'EOF_SVC' > "$SCRIPT_DIR/ds-service-manager.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$BASE_DIR/scripts"
PID_DIR="$BASE_DIR/run"

mkdir -p "$PID_DIR"

log() { echo "[DroidShell-SVC] $*"; }

cmd="${1:-help}"

case "$cmd" in
  start-updater)
    if [ -f "$PID_DIR/updater.pid" ] && kill -0 "$(cat "$PID_DIR/updater.pid")" 2>/dev/null; then
      log "Updater already running."
      exit 0
    fi
    nohup "$SCRIPTS/ds-updater-daemon.sh" 60 >/dev/null 2>&1 &
    echo $! > "$PID_DIR/updater.pid"
    log "Updater started with PID $(cat "$PID_DIR/updater.pid")"
    ;;
  stop-updater)
    if [ -f "$PID_DIR/updater.pid" ]; then
      kill "$(cat "$PID_DIR/updater.pid")" 2>/dev/null || true
      rm -f "$PID_DIR/updater.pid"
      log "Updater stopped."
    else
      log "No updater PID file."
    fi
    ;;
  status)
    if [ -f "$PID_DIR/updater.pid" ] && kill -0 "$(cat "$PID_DIR/updater.pid")" 2>/dev/null; then
      log "Updater running (PID $(cat "$PID_DIR/updater.pid"))."
    else
      log "Updater not running."
    fi
    ;;
  help|*)
    echo "DroidShell Service Manager"
    echo "Usage:"
    echo "  $0 start-updater"
    echo "  $0 stop-updater"
    echo "  $0 status"
    ;;
esac
EOF_SVC
chmod +x "$SCRIPT_DIR/ds-service-manager.sh"
log "[GEN] ds-service-manager.sh"

############################################
# 5) Web Console 2.0
############################################
cat << 'EOF_WEB2' > "$WEB_CONSOLE2_DIR/index.html"
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>DroidShell Web Console 2.0</title>
  <style>
    body { font-family: sans-serif; background: #000; color: #eee; padding: 1rem; }
    h1 { color: #6cf; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit,minmax(280px,1fr)); gap: 1rem; }
    .card { border: 1px solid #444; padding: 1rem; border-radius: 4px; background: #111; }
    pre { background: #000; padding: 0.5rem; overflow-x: auto; }
    button { background: #222; color: #eee; border: 1px solid #555; padding: 0.3rem 0.6rem; cursor: pointer; }
    button:hover { background: #333; }
  </style>
</head>
<body>
  <h1>DroidShell Web Console 2.0</h1>
  <div class="grid">
    <div class="card">
      <h2>OTA Metadata</h2>
      <pre id="ota">Loading...</pre>
    </div>
    <div class="card">
      <h2>Registry</h2>
      <pre id="reg">Loading...</pre>
    </div>
    <div class="card">
      <h2>API Health</h2>
      <button onclick="checkHealth()">Check /health</button>
      <pre id="health">Idle</pre>
    </div>
  </div>
  <script>
    function loadJSON(path, targetId) {
      fetch(path)
        .then(r => r.json())
        .then(j => { document.getElementById(targetId).textContent = JSON.stringify(j, null, 2); })
        .catch(e => { document.getElementById(targetId).textContent = 'Error: ' + e; });
    }
    function checkHealth() {
      fetch('http://127.0.0.1:8080/health')
        .then(r => r.json())
        .then(j => { document.getElementById('health').textContent = JSON.stringify(j, null, 2); })
        .catch(e => { document.getElementById('health').textContent = 'Error: ' + e; });
    }
    loadJSON('../../ota/metadata.json', 'ota');
    loadJSON('../../registry/index.json', 'reg');
  </script>
</body>
</html>
EOF_WEB2
log "[GEN] web/console2/index.html"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Services bundle — READY"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
