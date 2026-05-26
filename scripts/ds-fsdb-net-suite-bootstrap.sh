#!/usr/bin/env bash
# DroidShell FSDB + Networking Suite Bootstrap
# Generates:
#   - Filesystem Registry Suite
#   - Networking Layer Suite

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"

FSDB="$ROOT/fsdb"
NET="$ROOT/net"

mkdir -p "$SCRIPTS" "$FSDB" "$NET"

echo "[DroidShell] Installing FSDB + Networking Suite..."


###############################################
# 1. ds-fsdb.sh — filesystem registry
###############################################
cat > "$SCRIPTS/ds-fsdb.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Filesystem Registry
# Tracks file metadata, ownership, and mount info.

set -e

ROOT="/sdcard/DroidShell"
FSDB="$ROOT/fsdb"

mkdir -p "$FSDB"

cmd="$1"
file="$2"
owner="$3"

usage() {
    echo "Usage:"
    echo "  ds-fsdb.sh add <file> <owner>"
    echo "  ds-fsdb.sh del <file>"
    echo "  ds-fsdb.sh info <file>"
    echo "  ds-fsdb.sh list"
    exit 1
}

[ -z "$cmd" ] && usage

case "$cmd" in
    add)
        [ -z "$file" ] || [ -z "$owner" ] && usage
        meta="$FSDB/$(echo "$file" | sed 's|/|_|g').meta"
        echo "file=$file" > "$meta"
        echo "owner=$owner" >> "$meta"
        echo "mtime=$(date +%s)" >> "$meta"
        echo "[OK] Registered $file"
        ;;
    del)
        [ -z "$file" ] && usage
        rm -f "$FSDB/$(echo "$file" | sed 's|/|_|g').meta"
        echo "[OK] Removed $file"
        ;;
    info)
        [ -z "$file" ] && usage
        meta="$FSDB/$(echo "$file" | sed 's|/|_|g').meta"
        [ -f "$meta" ] && cat "$meta" || echo "(null)"
        ;;
    list)
        ls -1 "$FSDB"
        ;;
    *)
        usage
        ;;
esac
EOF

chmod +x "$SCRIPTS/ds-fsdb.sh"
echo "[DroidShell] ds-fsdb.sh installed."


###############################################
# 2. ds-locate.sh — locate files via FSDB
###############################################
cat > "$SCRIPTS/ds-locate.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Locate Command (FSDB-backed)

ROOT="/sdcard/DroidShell"
FSDB="$ROOT/fsdb"

query="$1"

[ -z "$query" ] && { echo "Usage: ds-locate.sh <pattern>"; exit 1; }

for f in "$FSDB"/*.meta; do
    [ -f "$f" ] || continue
    file=$(grep '^file=' "$f" | cut -d= -f2-)
    if echo "$file" | grep -qi "$query"; then
        echo "$file"
    fi
done
EOF

chmod +x "$SCRIPTS/ds-locate.sh"
echo "[DroidShell] ds-locate.sh installed."


###############################################
# 3. ds-fileinfo.sh — show metadata
###############################################
cat > "$SCRIPTS/ds-fileinfo.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell File Info Viewer (FSDB-backed)

ROOT="/sdcard/DroidShell"
FSDB="$ROOT/fsdb"

file="$1"
[ -z "$file" ] && { echo "Usage: ds-fileinfo.sh <file>"; exit 1; }

meta="$FSDB/$(echo "$file" | sed 's|/|_|g').meta"

if [ -f "$meta" ]; then
    cat "$meta"
else
    echo "(null)"
fi
EOF

chmod +x "$SCRIPTS/ds-fileinfo.sh"
echo "[DroidShell] ds-fileinfo.sh installed."


###############################################
# 4. ds-net.sh — virtual network interface manager
###############################################
cat > "$SCRIPTS/ds-net.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Virtual Network Interface Manager

set -e

ROOT="/sdcard/DroidShell"
NET="$ROOT/net"

mkdir -p "$NET"

cmd="$1"
iface="$2"
addr="$3"

usage() {
    echo "Usage:"
    echo "  ds-net.sh add <iface> <addr>"
    echo "  ds-net.sh del <iface>"
    echo "  ds-net.sh list"
    exit 1
}

case "$cmd" in
    add)
        [ -z "$iface" ] || [ -z "$addr" ] && usage
        echo "$addr" > "$NET/$iface.iface"
        echo "[OK] Added interface $iface ($addr)"
        ;;
    del)
        [ -z "$iface" ] && usage
        rm -f "$NET/$iface.iface"
        echo "[OK] Removed interface $iface"
        ;;
    list)
        for f in "$NET"/*.iface; do
            [ -f "$f" ] || continue
            iface=$(basename "$f" .iface)
            addr=$(cat "$f")
            echo "$iface - $addr"
        done
        ;;
    *)
        usage
        ;;
esac
EOF

chmod +x "$SCRIPTS/ds-net.sh"
echo "[DroidShell] ds-net.sh installed."


###############################################
# 5. ds-netstat.sh — routing + interface table
###############################################
cat > "$SCRIPTS/ds-netstat.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Network Status Viewer

ROOT="/sdcard/DroidShell"
NET="$ROOT/net"

printf "%-16s %-16s\n" "INTERFACE" "ADDRESS"
for f in "$NET"/*.iface; do
    [ -f "$f" ] || continue
    iface=$(basename "$f" .iface)
    addr=$(cat "$f")
    printf "%-16s %-16s\n" "$iface" "$addr"
done
EOF

chmod +x "$SCRIPTS/ds-netstat.sh"
echo "[DroidShell] ds-netstat.sh installed."


###############################################
# 6. ds-ping.sh — simulated ping
###############################################
cat > "$SCRIPTS/ds-ping.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Simulated Ping

ROOT="/sdcard/DroidShell"
NET="$ROOT/net"

target="$1"
[ -z "$target" ] && { echo "Usage: ds-ping.sh <address>"; exit 1; }

found=0
for f in "$NET"/*.iface; do
    [ -f "$f" ] || continue
    addr=$(cat "$f")
    if [ "$addr" = "$target" ]; then
        found=1
        break
    fi
done

if [ "$found" -eq 1 ]; then
    echo "PING $target: host reachable"
else
    echo "PING $target: host unreachable"
fi
EOF

chmod +x "$SCRIPTS/ds-ping.sh"
echo "[DroidShell] ds-ping.sh installed."


###############################################
# DONE
###############################################
echo "[DroidShell] FSDB + Networking Suite installation complete."
