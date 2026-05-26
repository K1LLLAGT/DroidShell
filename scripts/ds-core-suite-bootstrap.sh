#!/usr/bin/env bash
# DroidShell Core Suite Bootstrap
# Generates:
#   - etc/ simulation (etc/profile, etc/services, etc)
#   - ds-pkg.sh (package manager)
#   - ds-init.sh (init system)

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"
ETC="$ROOT/etc"
ETC_SERVICES="$ETC/services"
PKG_DB="$ROOT/.pkg-db"

mkdir -p "$SCRIPTS" "$ETC" "$ETC_SERVICES" "$PKG_DB"

echo "[DroidShell] Installing Core Suite..."

###############################################
# 1. etc/ simulation
###############################################

# etc/profile
cat > "$ETC/profile" <<'EOF'
# DroidShell /etc/profile simulation

ROOT="/sdcard/DroidShell"
ENV_FILE="$ROOT/ds-env.sh"

# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && source "$ENV_FILE"

# MOTD
[ -x "$ROOT/scripts/ds-motd.sh" ] && "$ROOT/scripts/ds-motd.sh"
EOF

# etc/services/example.service
cat > "$ETC_SERVICES/example.service" <<'EOF'
id=example
description=Example DroidShell service
after=
wants=
restart=on-failure
exec_start=/sdcard/DroidShell/scripts/ds-example-service.sh
EOF

echo "[DroidShell] etc/ simulation installed."


###############################################
# 2. ds-pkg.sh — package manager
###############################################
cat > "$SCRIPTS/ds-pkg.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Package Manager (minimal)
# Manages simple package records in .pkg-db

set -e

ROOT="/sdcard/DroidShell"
DB="$ROOT/.pkg-db"

mkdir -p "$DB"

cmd="$1"
name="$2"
meta="$3"

usage() {
    echo "Usage:"
    echo "  ds-pkg.sh install <name> [meta]"
    echo "  ds-pkg.sh remove <name>"
    echo "  ds-pkg.sh list"
    echo "  ds-pkg.sh info <name>"
    exit 1
}

[ -z "$cmd" ] && usage

case "$cmd" in
    install)
        [ -z "$name" ] && usage
        echo "${meta:-installed}" > "$DB/$name"
        echo "[OK] Installed package: $name"
        ;;
    remove)
        [ -z "$name" ] && usage
        rm -f "$DB/$name"
        echo "[OK] Removed package: $name"
        ;;
    list)
        ls -1 "$DB"
        ;;
    info)
        [ -z "$name" ] && usage
        if [ -f "$DB/$name" ]; then
            echo "$name: $(cat "$DB/$name")"
        else
            echo "[MISS] Package not found: $name"
        fi
        ;;
    *)
        usage
        ;;
esac
EOF

chmod +x "$SCRIPTS/ds-pkg.sh"
echo "[DroidShell] ds-pkg.sh installed."


###############################################
# 3. ds-init.sh — init system
###############################################
cat > "$SCRIPTS/ds-init.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Init System (minimal)
# Starts services defined in etc/services/*.service

set -e

ROOT="/sdcard/DroidShell"
ETC_SERVICES="$ROOT/etc/services"
RUNTIME="$ROOT/.runtime"

mkdir -p "$RUNTIME"

cmd="$1"

usage() {
    echo "Usage:"
    echo "  ds-init.sh boot"
    echo "  ds-init.sh list"
    exit 1
}

[ -z "$cmd" ] && usage

list_services() {
    for f in "$ETC_SERVICES"/*.service; do
        [ -f "$f" ] || continue
        id=$(grep '^id=' "$f" | head -n1 | cut -d= -f2-)
        desc=$(grep '^description=' "$f" | head -n1 | cut -d= -f2-)
        echo "$id - $desc"
    done
}

start_services() {
    echo "[DroidShell] Starting services from $ETC_SERVICES..."
    for f in "$ETC_SERVICES"/*.service; do
        [ -f "$f" ] || continue
        id=$(grep '^id=' "$f" | head -n1 | cut -d= -f2-)
        exec_start=$(grep '^exec_start=' "$f" | head -n1 | cut -d= -f2-)
        log="$RUNTIME/$id.service.log"

        if [ -x "$exec_start" ]; then
            echo "  [START] $id -> $exec_start"
            "$exec_start" >> "$log" 2>&1 &
        else
            echo "  [SKIP] $id (exec_start not executable: $exec_start)"
        fi
    done
}

case "$cmd" in
    list)
        list_services
        ;;
    boot)
        start_services
        ;;
    *)
        usage
        ;;
esac
EOF

chmod +x "$SCRIPTS/ds-init.sh"
echo "[DroidShell] ds-init.sh installed."


###############################################
# DONE
###############################################
echo "[DroidShell] Core Suite installation complete."
