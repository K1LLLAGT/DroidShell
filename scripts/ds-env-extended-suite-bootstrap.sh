#!/usr/bin/env bash
# DroidShell Extended Environment Suite Bootstrap
# Generates:
#   - ds-env-report.sh
#   - ds-motd.sh
#   - ds-env-registry.sh

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"
REG="$ROOT/.env-registry"

mkdir -p "$SCRIPTS" "$REG"

echo "[DroidShell] Installing Extended Environment Suite..."


###############################################
# 1. ds-env-report.sh
###############################################
cat > "$SCRIPTS/ds-env-report.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Environment Report Generator
# Produces a full diagnostic report of the environment.

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"
ENV_FILE="$ROOT/ds-env.sh"
REG="$ROOT/.env-registry"

OUT="$ROOT/.runtime/env-report.txt"
mkdir -p "$ROOT/.runtime"

echo "[DroidShell] Generating environment report..."
{
    echo "==============================="
    echo "DroidShell Environment Report"
    echo "==============================="
    echo
    echo "Timestamp: $(date)"
    echo
    echo "---- PATH ----"
    echo "$PATH" | tr ':' '\n'
    echo
    echo "---- Environment File ----"
    [ -f "$ENV_FILE" ] && cat "$ENV_FILE" || echo "MISSING"
    echo
    echo "---- Scripts Directory ----"
    ls -1 "$SCRIPTS"
    echo
    echo "---- Registry ----"
    ls -1 "$REG" 2>/dev/null || echo "(empty)"
    echo
    echo "---- Shell Info ----"
    echo "SHELL: $SHELL"
    echo "USER: $USER"
    echo "HOME: $HOME"
    echo
} > "$OUT"

echo "[DroidShell] Report written to $OUT"
EOF

chmod +x "$SCRIPTS/ds-env-report.sh"
echo "[DroidShell] ds-env-report.sh installed."


###############################################
# 2. ds-motd.sh
###############################################
cat > "$SCRIPTS/ds-motd.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell MOTD (Message of the Day)
# Displays a login banner for DroidShell shells.

ROOT="/sdcard/DroidShell"
VERSION_FILE="$ROOT/VERSION"

VERSION="unknown"
[ -f "$VERSION_FILE" ] && VERSION=$(cat "$VERSION_FILE")

echo "======================================="
echo "      Welcome to DroidShell OS"
echo "======================================="
echo "Version: $VERSION"
echo "Root: $ROOT"
echo "Scripts: $ROOT/scripts"
echo "Runtime: $ROOT/.runtime"
echo "======================================="
EOF

chmod +x "$SCRIPTS/ds-motd.sh"
echo "[DroidShell] ds-motd.sh installed."


###############################################
# 3. ds-env-registry.sh
###############################################
cat > "$SCRIPTS/ds-env-registry.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Environment Variable Registry
# Allows storing, retrieving, listing, and deleting OS-level variables.

set -e

ROOT="/sdcard/DroidShell"
REG="$ROOT/.env-registry"

mkdir -p "$REG"

cmd="$1"
key="$2"
val="$3"

case "$cmd" in
    set)
        [ -z "$key" ] && { echo "Usage: ds-env-registry.sh set <key> <value>"; exit 1; }
        echo "$val" > "$REG/$key"
        echo "[OK] Set $key"
        ;;
    get)
        [ -z "$key" ] && { echo "Usage: ds-env-registry.sh get <key>"; exit 1; }
        if [ -f "$REG/$key" ]; then
            cat "$REG/$key"
        else
            echo "(null)"
        fi
        ;;
    del)
        [ -z "$key" ] && { echo "Usage: ds-env-registry.sh del <key>"; exit 1; }
        rm -f "$REG/$key"
        echo "[OK] Deleted $key"
        ;;
    list)
        ls -1 "$REG"
        ;;
    *)
        echo "Usage:"
        echo "  ds-env-registry.sh set <key> <value>"
        echo "  ds-env-registry.sh get <key>"
        echo "  ds-env-registry.sh del <key>"
        echo "  ds-env-registry.sh list"
        exit 1
        ;;
esac
EOF

chmod +x "$SCRIPTS/ds-env-registry.sh"
echo "[DroidShell] ds-env-registry.sh installed."


###############################################
# DONE
###############################################
echo "[DroidShell] Extended Environment Suite installation complete."
