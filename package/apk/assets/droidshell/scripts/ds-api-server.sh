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
