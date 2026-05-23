#!/usr/bin/env bash
# ds-root-advanced.sh
# Advanced root features: widgets, Magisk hooks, signing, OTA, TUI, JSON API, module manager, snapshot/rollback.

set -euo pipefail

BANNER="
  ____            _     _ ____  _          _ _
 |  _ \ _ __ ___ (_) __| / ___|| |__   ___| | |
 | | | | '__/ _ \| |/ _\` \___ \| '_ \ / _ \ | |
 | |_| | | | (_) | | (_| |___) | | | |  __/ | |
 |____/|_|  \___/|_|\__,_|____/|_| |_|\___|_|_|
  Root Advanced  · widgets · TUI · OTA · API
"

echo "$BANNER"
echo
echo "Targets:"
echo "  • /sdcard/Documents/DroidShell"
echo "  • $HOME/DroidShell"
echo

TARGETS=(
  "/sdcard/Documents/DroidShell"
  "$HOME/DroidShell"
)

for BASE in "${TARGETS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " Integrating advanced features in: $BASE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  ROOT_DIR="$BASE/root"
  MOD_DIR="$ROOT_DIR/modules"
  SCRIPTS_DIR="$BASE/scripts"
  MAGISK_DIR="$BASE/magisk-droidshell"
  DS_ROOT="$BASE/ds_root.sh"

  mkdir -p "$MOD_DIR" "$SCRIPTS_DIR" "$MAGISK_DIR"

  ############################################
  # 1) Root dashboard widgets (shell helpers)
  ############################################
  cat << 'W1' > "$ROOT_DIR/dashboard_widgets.sh"
#!/usr/bin/env bash
set -euo pipefail

ds_widget_battery() {
  echo "[Battery]"
  su -c "dumpsys battery 2>/dev/null | sed 's/^/  /'" || echo "  (no dumpsys battery)"
  echo
}

ds_widget_selinux() {
  echo "[SELinux]"
  su -c "getenforce 2>/dev/null | sed 's/^/  Mode: /'" || echo "  (no getenforce)"
  echo
}

ds_widget_magisk() {
  echo "[Magisk]"
  if su -c "magisk -v" >/dev/null 2>&1; then
    su -c "magisk -v 2>/dev/null | sed 's/^/  /'"
  else
    echo "  Magisk: not detected"
  fi
  echo
}
W1
  chmod +x "$ROOT_DIR/dashboard_widgets.sh"
  echo "[GEN] dashboard_widgets.sh"

  ############################################
  # 2) TUI (simple dialog-based interface)
  ############################################
  cat << 'TUI' > "$SCRIPTS_DIR/ds-root-tui.sh"
#!/usr/bin/env bash
set -euo pipefail

ROOT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DS_ROOT="$ROOT_BASE_DIR/ds_root.sh"

if ! command -v dialog >/dev/null 2>&1; then
  echo "[!] dialog not installed. Install: pkg install dialog"
  exit 1
fi

main_menu() {
  CHOICE=$(dialog --clear --stdout \
    --backtitle "DroidShell Root TUI" \
    --title "Root Console" \
    --menu "Select action:" 15 60 6 \
      1 "Dashboard" \
      2 "Core tools" \
      3 "Extra modules" \
      4 "Module manager" \
      5 "JSON API info" \
      0 "Quit")
  case "$CHOICE" in
    1) "$DS_ROOT" menu ;;   # uses existing menu path
    2) "$DS_ROOT" menu ;;
    3) "$DS_ROOT" menu ;;
    4) "$ROOT_BASE_DIR/scripts/ds-root-module-manager.sh" ;;
    5) "$ROOT_BASE_DIR/scripts/ds-root-api.sh" info ;;
    0) clear; exit 0 ;;
    *) main_menu ;;
  esac
}

main_menu
TUI
  chmod +x "$SCRIPTS_DIR/ds-root-tui.sh"
  echo "[GEN] ds-root-tui.sh"

  ############################################
  # 3) JSON API for external tools
  ############################################
  cat << 'API' > "$SCRIPTS_DIR/ds-root-api.sh"
#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-info}"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

case "$CMD" in
  info)
    OEM=$(su -c "getprop ro.product.manufacturer 2>/dev/null" || echo "unknown")
    MODEL=$(su -c "getprop ro.product.model 2>/dev/null" || echo "unknown")
    ANDROID=$(su -c "getprop ro.build.version.release 2>/dev/null" || echo "unknown")
    ROOT="false"
    if command -v su >/dev/null 2>&1; then ROOT="true"; fi
    echo "{"
    echo "  \"oem\": \"$(json_escape "$OEM")\","
    echo "  \"model\": \"$(json_escape "$MODEL")\","
    echo "  \"android\": \"$(json_escape "$ANDROID")\","
    echo "  \"root\": $ROOT"
    echo "}"
    ;;
  *)
    echo "Usage: $0 info"
    exit 1
    ;;
esac
API
  chmod +x "$SCRIPTS_DIR/ds-root-api.sh"
  echo "[GEN] ds-root-api.sh"

  ############################################
  # 4) Module signing + verification (simple hash-based)
  ############################################
  cat << 'SIG' > "$SCRIPTS_DIR/ds-root-sign.sh"
#!/usr/bin/env bash
set -euo pipefail

MOD_DIR="${1:-root/modules}"
OUT="${2:-root/modules.SHA256}"

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "[!] sha256sum not available."
  exit 1
fi

> "$OUT"
for f in "$MOD_DIR"/*.sh; do
  [ -f "$f" ] || continue
  sha256sum "$f" >> "$OUT"
done

echo "[+] Wrote signatures to $OUT"
SIG
  chmod +x "$SCRIPTS_DIR/ds-root-sign.sh"
  echo "[GEN] ds-root-sign.sh"

  cat << 'VER' > "$SCRIPTS_DIR/ds-root-verify.sh"
#!/usr/bin/env bash
set -euo pipefail

MOD_DIR="${1:-root/modules}"
SIG_FILE="${2:-root/modules.SHA256}"

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "[!] sha256sum not available."
  exit 1
fi

if [ ! -f "$SIG_FILE" ]; then
  echo "[!] Signature file not found: $SIG_FILE"
  exit 1
fi

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

cp "$SIG_FILE" "$TMP"
pushd "$MOD_DIR" >/dev/null 2>&1
sha256sum -c "$TMP"
popd >/dev/null 2>&1
VER
  chmod +x "$SCRIPTS_DIR/ds-root-verify.sh"
  echo "[GEN] ds-root-verify.sh"

  ############################################
  # 5) OTA-style update system for root modules (pull from GitHub)
  ############################################
  cat << 'OTA' > "$MOD_DIR/root_ota.sh"
#!/usr/bin/env bash
set -euo pipefail

REPO="K1LLLAGT/DroidShell"
BRANCH="${1:-main}"
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[+] Fetching latest modules from $REPO@$BRANCH..."
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -L "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" -o "$TMP/src.tar.gz"
tar -xzf "$TMP/src.tar.gz" -C "$TMP"

SUBDIR=$(find "$TMP" -maxdepth 1 -type d -name "DroidShell-*")
if [ -z "$SUBDIR" ]; then
  echo "[!] Could not locate extracted repo."
  exit 1
fi

if [ -d "$SUBDIR/root/modules" ]; then
  cp "$SUBDIR/root/modules/"*.sh "$TARGET_DIR"/
  echo "[+] Modules updated in $TARGET_DIR"
else
  echo "[!] No root/modules directory in archive."
fi
OTA
  chmod +x "$MOD_DIR/root_ota.sh"
  echo "[GEN] root_ota.sh"

  ############################################
  # 6) Module manager UI (simple shell menu)
  ############################################
  cat << 'MM' > "$SCRIPTS_DIR/ds-root-module-manager.sh"
#!/usr/bin/env bash
set -euo pipefail

ROOT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOD_DIR="$ROOT_BASE_DIR/root/modules"
STATE_FILE="$ROOT_BASE_DIR/root/modules.state"

mkdir -p "$MOD_DIR"
touch "$STATE_FILE"

list_modules() {
  echo "Modules:"
  i=1
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    enabled="on"
    if grep -q "^$name:off$" "$STATE_FILE"; then
      enabled="off"
    fi
    printf "  %2d) %-20s [%s]\n" "$i" "$name" "$enabled"
    i=$((i+1))
  done < <(ls "$MOD_DIR"/*.sh 2>/dev/null)
}

toggle_module() {
  name="$1"
  grep -v "^$name:" "$STATE_FILE" > "$STATE_FILE.tmp" || true
  mv "$STATE_FILE.tmp" "$STATE_FILE"
  if grep -q "^$name:off$" "$STATE_FILE" 2>/dev/null; then
    sed -i "s/^$name:off$/$name:on/" "$STATE_FILE"
  else
    echo "$name:off" >> "$STATE_FILE"
  fi
}

while true; do
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " Root Module Manager"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  list_modules
  echo
  echo "Enter module name to toggle, or 'q' to quit:"
  read -r ans
  case "$ans" in
    q|Q) exit 0 ;;
    *)
      if [ -f "$MOD_DIR/$ans" ]; then
        toggle_module "$ans"
      else
        echo "No such module: $ans"
        sleep 1
      fi
      ;;
  esac
done
MM
  chmod +x "$SCRIPTS_DIR/ds-root-module-manager.sh"
  echo "[GEN] ds-root-module-manager.sh"

  ############################################
  # 7) Snapshot + rollback (root modules/config only)
  ############################################
  SNAP_DIR="$ROOT_DIR/snapshots"
  mkdir -p "$SNAP_DIR"

  cat << 'SNAP' > "$SCRIPTS_DIR/ds-root-snapshot.sh"
#!/usr/bin/env bash
set -euo pipefail

ROOT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOD_DIR="$ROOT_BASE_DIR/root/modules"
STATE_FILE="$ROOT_BASE_DIR/root/modules.state"
SNAP_DIR="$ROOT_BASE_DIR/root/snapshots"

mkdir -p "$SNAP_DIR"

STAMP=$(date +"%Y%m%d-%H%M%S")
ARCHIVE="$SNAP_DIR/snapshot-$STAMP.tar.gz"

tar -czf "$ARCHIVE" -C "$ROOT_BASE_DIR" root/modules root/modules.state 2>/dev/null || \
tar -czf "$ARCHIVE" -C "$ROOT_BASE_DIR" root/modules 2>/dev/null

echo "[+] Snapshot created: $ARCHIVE"
SNAP
  chmod +x "$SCRIPTS_DIR/ds-root-snapshot.sh"
  echo "[GEN] ds-root-snapshot.sh"

  cat << 'ROLL' > "$SCRIPTS_DIR/ds-root-rollback.sh"
#!/usr/bin/env bash
set -euo pipefail

ROOT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SNAP_DIR="$ROOT_BASE_DIR/root/snapshots"

SNAP="${1:-}"

if [ -z "$SNAP" ]; then
  echo "Available snapshots:"
  ls -1 "$SNAP_DIR"/snapshot-*.tar.gz 2>/dev/null || echo "  (none)"
  echo
  echo "Usage: $0 <snapshot-file>"
  exit 0
fi

if [ ! -f "$SNAP" ]; then
  echo "[!] Snapshot not found: $SNAP"
  exit 1
fi

tar -xzf "$SNAP" -C "$ROOT_BASE_DIR"
echo "[+] Restored from snapshot: $SNAP"
ROLL
  chmod +x "$SCRIPTS_DIR/ds-root-rollback.sh"
  echo "[GEN] ds-root-rollback.sh"

  ############################################
  # 8) Magisk service hooks (extend existing service.sh)
  ############################################
  SERVICE_SH="$MAGISK_DIR/service.sh"
  if [ -f "$SERVICE_SH" ] && ! grep -q "DS_ROOT_ADVANCED_HOOKS" "$SERVICE_SH"; then
    cat << 'MS' >> "$SERVICE_SH"

# DS_ROOT_ADVANCED_HOOKS
MODDIR=\${0%/*}
# Example hook: log and touch a marker
log -t droidshell "DroidShell advanced Magisk service hook active: $MODDIR"
touch "$MODDIR/droidshell.service.active"
MS
    echo "[MERGE] extended Magisk service.sh → $SERVICE_SH"
  else
    echo "[SKIP] Magisk service.sh already patched or missing."
  fi

  ############################################
  # 9) Wire widgets into ds_root dashboard if present
  ############################################
  if [ -f "$DS_ROOT" ] && ! grep -q "DS_ROOT_WIDGETS_HOOK" "$DS_ROOT"; then
    cat << 'HOOK' >> "$DS_ROOT"

# DS_ROOT_WIDGETS_HOOK
if [ -f "\$ROOT_BASE_DIR/root/dashboard_widgets.sh" ]; then
  . "\$ROOT_BASE_DIR/root/dashboard_widgets.sh"
fi

# Override/extend root_dashboard if widgets available
if command -v ds_widget_battery >/dev/null 2>&1; then
  root_dashboard() {
    clear
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " DroidShell · Root Dashboard (widgets)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    ds_widget_battery
    ds_widget_selinux
    ds_widget_magisk
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " [m] Main menu   [q] Quit"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    read -r -p "Choice: " ans
    case "$ans" in
      m|M) root_main_menu ;;
      q|Q) exit 0 ;;
      *) root_dashboard ;;
    esac
  }
fi
HOOK
    echo "[MERGE] wired widgets into ds_root.sh → $DS_ROOT"
  else
    echo "[SKIP] ds_root.sh already has widgets hook or missing."
  fi

  echo "✓ Advanced integration complete for $BASE"
done

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Root Advanced — Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
