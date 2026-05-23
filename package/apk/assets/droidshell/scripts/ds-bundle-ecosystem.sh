#!/usr/bin/env bash
# ds-bundle-ecosystem.sh
# Adds:
# - OTA client
# - Updater daemon
# - CLI package manager
# - Web registry browser
# - Web console

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$BASE_DIR/scripts"
OTA_DIR="$BASE_DIR/ota"
OUT_DIR="$BASE_DIR/out"
REG_DIR="$BASE_DIR/registry"
WEB_DIR="$BASE_DIR/web"
WEB_REG_DIR="$WEB_DIR/registry"
WEB_CONSOLE_DIR="$WEB_DIR/console"

mkdir -p "$SCRIPT_DIR" "$OTA_DIR" "$OUT_DIR" "$REG_DIR" "$WEB_REG_DIR" "$WEB_CONSOLE_DIR"

log() { echo "[DroidShell-Bundle] $*"; }

log "Base dir: $BASE_DIR"

############################################
# 1) OTA client (device-side updater)
############################################
cat << 'EOF_OTA_CLIENT' > "$SCRIPT_DIR/ds-ota-client.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OTA_DIR="$BASE_DIR/ota"
OUT_DIR="$BASE_DIR/out"
META_FILE="$OTA_DIR/metadata.json"

log() { echo "[DroidShell-OTA-Client] $*"; }

if [ ! -f "$META_FILE" ]; then
  log "No metadata.json found at $META_FILE"
  exit 1
fi

channel="${1:-stable}"

jq_bin="$(command -v jq || true)"
if [ -z "$jq_bin" ]; then
  log "jq is required. Install: pkg install jq"
  exit 1
fi

root_url="$(jq -r ".channels.$channel.root" "$META_FILE")"
nonroot_url="$(jq -r ".channels.$channel.nonroot" "$META_FILE")"

if [ -z "$root_url" ] && [ -z "$nonroot_url" ]; then
  log "No URLs configured for channel '$channel'"
  exit 1
fi

is_root() {
  if command -v su >/dev/null 2>&1 && su -c "id -u" 2>/dev/null | grep -q '^0$'; then
    return 0
  fi
  return 1
}

mkdir -p "$OUT_DIR"

if is_root && [ -n "$root_url" ]; then
  log "Root detected, using root package: $root_url"
  pkg_path="$OUT_DIR/droidshell-root-update.zip"
  curl -L "$root_url" -o "$pkg_path"
  log "Downloaded: $pkg_path"
  log "Flash this via recovery/Magisk or your preferred method."
elif [ -n "$nonroot_url" ]; then
  log "No root or root package unavailable, using non-root package: $nonroot_url"
  pkg_path="$OUT_DIR/droidshell-nonroot-update.zip"
  curl -L "$nonroot_url" -o "$pkg_path"
  log "Downloaded: $pkg_path"
  log "Install/update according to your non-root distribution method."
else
  log "No suitable package found for this device/channel."
  exit 1
fi
EOF_OTA_CLIENT
chmod +x "$SCRIPT_DIR/ds-ota-client.sh"
log "[GEN] ds-ota-client.sh"

############################################
# 2) Updater daemon (simple loop)
############################################
cat << 'EOF_DAEMON' > "$SCRIPT_DIR/ds-updater-daemon.sh"
#!/usr/bin/env bash
set -euo pipefail

INTERVAL_MIN="${1:-60}"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$BASE_DIR/scripts"

log() { echo "[DroidShell-Updater] $*"; }

while true; do
  log "Checking for updates (channel: stable)..."
  if [ -x "$SCRIPT_DIR/ds-ota-client.sh" ]; then
    "$SCRIPT_DIR/ds-ota-client.sh" stable || log "Update check failed."
  else
    log "ds-ota-client.sh not found."
  fi
  log "Sleeping ${INTERVAL_MIN} minutes..."
  sleep "$((INTERVAL_MIN * 60))"
done
EOF_DAEMON
chmod +x "$SCRIPT_DIR/ds-updater-daemon.sh"
log "[GEN] ds-updater-daemon.sh"

############################################
# 3) CLI package manager (registry-based)
############################################
cat << 'EOF_PKG' > "$SCRIPT_DIR/ds-pkg.sh"
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REG_DIR="$BASE_DIR/registry"
INDEX="$REG_DIR/index.json"
PKG_DIR="$REG_DIR/packages"

jq_bin="$(command -v jq || true)"
if [ -z "$jq_bin" ]; then
  echo "[DroidShell-PKG] jq is required. Install: pkg install jq"
  exit 1
fi

cmd="${1:-help}"
arg="${2:-}"

case "$cmd" in
  list)
    jq -r '.packages[] | "- \(.name) -> \(.file)"' "$INDEX"
    ;;
  info)
    if [ -z "$arg" ]; then
      echo "Usage: $0 info <name>"
      exit 1
    fi
    jq -r ".packages[] | select(.name==\"$arg\")" "$INDEX"
    ;;
  install)
    if [ -z "$arg" ]; then
      echo "Usage: $0 install <name>"
      exit 1
    fi
    file="$(jq -r ".packages[] | select(.name==\"$arg\") | .file" "$INDEX")"
    if [ -z "$file" ] || [ "$file" = "null" ]; then
      echo "[DroidShell-PKG] Package not found: $arg"
      exit 1
    fi
    full="$PKG_DIR/$(basename "$file")"
    if [ ! -f "$full" ]; then
      echo "[DroidShell-PKG] File missing: $full"
      exit 1
    fi
    echo "[DroidShell-PKG] Installing $arg from $full"
    # For now, just echo; you can define install semantics per package type.
    ;;
  help|*)
    echo "DroidShell Package Manager"
    echo "Usage:"
    echo "  $0 list"
    echo "  $0 info <name>"
    echo "  $0 install <name>"
    ;;
esac
EOF_PKG
chmod +x "$SCRIPT_DIR/ds-pkg.sh"
log "[GEN] ds-pkg.sh"

############################################
# 4) Web registry browser
############################################
cat << 'EOF_WEB_REG' > "$WEB_REG_DIR/index.html"
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>DroidShell Registry</title>
  <style>
    body { font-family: sans-serif; background: #111; color: #eee; padding: 1rem; }
    h1 { color: #6cf; }
    .pkg { border: 1px solid #444; padding: 0.5rem 1rem; margin-bottom: 0.5rem; border-radius: 4px; }
    code { color: #9f9; }
  </style>
</head>
<body>
  <h1>DroidShell Package Registry</h1>
  <div id="list">Loading...</div>
  <script>
    fetch('../../registry/index.json')
      .then(r => r.json())
      .then(j => {
        const list = document.getElementById('list');
        list.innerHTML = '';
        if (!j.packages || !j.packages.length) {
          list.textContent = 'No packages registered.';
          return;
        }
        j.packages.forEach(p => {
          const div = document.createElement('div');
          div.className = 'pkg';
          div.innerHTML = '<strong>' + p.name + '</strong><br><code>' + p.file + '</code>';
          list.appendChild(div);
        });
      })
      .catch(e => {
        document.getElementById('list').textContent = 'Error loading registry: ' + e;
      });
  </script>
</body>
</html>
EOF_WEB_REG
log "[GEN] web/registry/index.html"

############################################
# 5) Web console
############################################
cat << 'EOF_WEB_CONSOLE' > "$WEB_CONSOLE_DIR/index.html"
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>DroidShell Console</title>
  <style>
    body { font-family: sans-serif; background: #000; color: #eee; padding: 1rem; }
    h1 { color: #6cf; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit,minmax(280px,1fr)); gap: 1rem; }
    .card { border: 1px solid #444; padding: 1rem; border-radius: 4px; background: #111; }
    pre { background: #000; padding: 0.5rem; overflow-x: auto; }
  </style>
</head>
<body>
  <h1>DroidShell Web Console</h1>
  <div class="grid">
    <div class="card">
      <h2>OTA Metadata</h2>
      <pre id="ota">Loading...</pre>
    </div>
    <div class="card">
      <h2>Registry</h2>
      <pre id="reg">Loading...</pre>
    </div>
  </div>
  <script>
    fetch('../../ota/metadata.json')
      .then(r => r.json())
      .then(j => { document.getElementById('ota').textContent = JSON.stringify(j, null, 2); })
      .catch(e => { document.getElementById('ota').textContent = 'Error: ' + e; });

    fetch('../../registry/index.json')
      .then(r => r.json())
      .then(j => { document.getElementById('reg').textContent = JSON.stringify(j, null, 2); })
      .catch(e => { document.getElementById('reg').textContent = 'Error: ' + e; });
  </script>
</body>
</html>
EOF_WEB_CONSOLE
log "[GEN] web/console/index.html"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Ecosystem bundle — READY"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
