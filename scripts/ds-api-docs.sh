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
