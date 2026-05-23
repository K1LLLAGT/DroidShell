#!/usr/bin/env bash
# ds-dual-system.sh
# Dual build system + Magisk-aware installer + unified OTA + QR installer.

set -euo pipefail

BANNER="
  ____            _     _ ____  _          _ _
 |  _ \ _ __ ___ (_) __| / ___|| |__   ___| | |
 | | | | '__/ _ \| |/ _\` \___ \| '_ \ / _ \ | |
 | |_| | | | (_) | | (_| |___) | | | |  __/ | |
 |____/|_|  \___/|_|\__,_|____/|_| |_|\___|_|_|
  Dual System  · root/non-root · OTA · QR
"

echo "$BANNER"
echo

BASE_DIR="$(pwd)"
SCRIPT_DIR="$BASE_DIR/scripts"
OUT_DIR="$BASE_DIR/out"

mkdir -p "$SCRIPT_DIR" "$OUT_DIR"

############################################
# 1) Dual build system (root + non-root packages)
############################################
cat << 'BUILD' > "$SCRIPT_DIR/ds-build-dual.sh"
#!/usr/bin/env bash
# ds-build-dual.sh - build root + non-root DroidShell packages (zip-based)

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$BASE_DIR/out"
ROOT_PKG="$OUT_DIR/droidshell-root.zip"
NONROOT_PKG="$OUT_DIR/droidshell-nonroot.zip"

mkdir -p "$OUT_DIR"

echo "[+] Building non-root package → $NONROOT_PKG"
cd "$BASE_DIR"
zip -r "$NONROOT_PKG" root scripts ds_root.sh \
  -x "root/*modules/*" \
  -x "root/*magisk*" \
  >/dev/null

echo "[+] Building root package → $ROOT_PKG"
cd "$BASE_DIR"
zip -r "$ROOT_PKG" root scripts ds_root.sh magisk-droidshell \
  >/dev/null

echo "[✓] Built:"
echo "  $NONROOT_PKG"
echo "  $ROOT_PKG"
BUILD
chmod +x "$SCRIPT_DIR/ds-build-dual.sh"
echo "[GEN] ds-build-dual.sh"

############################################
# 2) Magisk-aware installer (Magisk vs SuperSU vs KernelSU)
############################################
cat << 'INST' > "$SCRIPT_DIR/ds-install-universal.sh"
#!/usr/bin/env bash
# ds-install-universal.sh
# Auto-detect root stack + install root or non-root package.

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$BASE_DIR/out"
ROOT_ZIP="$OUT_DIR/droidshell-root.zip"
NONROOT_ZIP="$OUT_DIR/droidshell-nonroot.zip"

log() { echo "[DroidShell-Install] $*"; }

detect_root_stack() {
  if command -v su >/dev/null 2>&1; then
    if su -c "magisk -v" >/dev/null 2>&1; then
      echo "Magisk"
      return 0
    fi
    if su -v 2>/dev/null | grep -qi "supersu"; then
      echo "SuperSU"
      return 0
    fi
    if su -c "uname -a" 2>/dev/null | grep -qi "kernelsu"; then
      echo "KernelSU"
      return 0
    fi
    echo "GenericSU"
    return 0
  fi
  echo "NoRoot"
}

is_root_working() {
  if ! command -v su >/dev/null 2>&1; then
    return 1
  fi
  if ! su -c "id" >/dev/null 2>&1; then
    return 1
  fi
  UID="$(su -c "id -u" 2>/dev/null || echo 1)"
  [ "$UID" = "0" ]
}

STACK="$(detect_root_stack)"
log "Detected root stack: $STACK"

if is_root_working; then
  log "Root is functional."
  if [ ! -f "$ROOT_ZIP" ]; then
    log "Root package not found: $ROOT_ZIP"
    exit 1
  fi
  log "Root install path depends on environment:"
  log "  • For Magisk: flash $ROOT_ZIP in Magisk Manager."
  log "  • For others: unpack and deploy manually (non-automated for safety)."
else
  log "No functional root. Using non-root package."
  if [ ! -f "$NONROOT_ZIP" ]; then
    log "Non-root package not found: $NONROOT_ZIP"
    exit 1
  fi
  log "Non-root package ready at: $NONROOT_ZIP"
  log "Install method depends on how DroidShell is distributed (APK, zip, etc.)."
fi
INST
chmod +x "$SCRIPT_DIR/ds-install-universal.sh"
echo "[GEN] ds-install-universal.sh"

############################################
# 3) Unified OTA updater (root + non-root)
############################################
cat << 'OTA' > "$SCRIPT_DIR/ds-ota-unified.sh"
#!/usr/bin/env bash
# ds-ota-unified.sh
# Unified OTA updater for root + non-root DroidShell packages.

set -euo pipefail

REPO="K1LLLAGT/DroidShell"
BRANCH="${1:-main}"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$BASE_DIR/out"
mkdir -p "$OUT_DIR"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

log() { echo "[DroidShell-OTA] $*"; }

log "Fetching latest from $REPO@$BRANCH..."
curl -L "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" -o "$TMP/src.tar.gz"

tar -xzf "$TMP/src.tar.gz" -C "$TMP"
SUBDIR="$(find "$TMP" -maxdepth 1 -type d -name "DroidShell-*")"

if [ -z "$SUBDIR" ]; then
  log "Could not locate extracted repo."
  exit 1
fi

log "Rebuilding dual packages from latest source..."
cd "$SUBDIR"
if [ -x "scripts/ds-dual-system.sh" ]; then
  ./scripts/ds-dual-system.sh
fi
if [ -x "scripts/ds-build-dual.sh" ]; then
  ./scripts/ds-build-dual.sh
fi

if [ -d "$SUBDIR/out" ]; then
  cp "$SUBDIR/out/"droidshell-*.zip "$OUT_DIR"/
  log "Updated packages copied to: $OUT_DIR"
else
  log "No out/ directory found in latest build."
fi
OTA
chmod +x "$SCRIPT_DIR/ds-ota-unified.sh"
echo "[GEN] ds-ota-unified.sh"

############################################
# 4) QR-code installer that auto-detects root
############################################
cat << 'QR' > "$SCRIPT_DIR/ds-qr-installer.sh"
#!/usr/bin/env bash
# ds-qr-installer.sh
# Generate a QR code for a universal install command.

set -euo pipefail

if ! command -v qrencode >/dev/null 2>&1; then
  echo "[!] qrencode not installed. Install: pkg install qrencode"
  exit 1
fi

# This URL should point to a hosted copy of ds-install-universal.sh
INSTALL_URL="${1:-https://github.com/K1LLLAGT/DroidShell/raw/main/scripts/ds-install-universal.sh}"

CMD="curl -sSL \"$INSTALL_URL\" -o ds-install-universal.sh && chmod +x ds-install-universal.sh && ./ds-install-universal.sh"

echo "[+] Command encoded in QR:"
echo "    $CMD"
echo
qrencode -t ANSIUTF8 "$CMD"
QR
chmod +x "$SCRIPT_DIR/ds-qr-installer.sh"
echo "[GEN] ds-qr-installer.sh"

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Dual System · Installer · OTA · QR — Ready"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Build dual packages:  $SCRIPT_DIR/ds-build-dual.sh"
echo "  Universal installer:  $SCRIPT_DIR/ds-install-universal.sh"
echo "  Unified OTA updater:  $SCRIPT_DIR/ds-ota-unified.sh"
echo "  QR installer helper:  $SCRIPT_DIR/ds-qr-installer.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
