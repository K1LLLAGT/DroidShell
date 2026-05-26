#!/usr/bin/env bash
# DroidShell Supervisor Suite Bootstrap
# Generates:
#   - ds-supervisor.sh (process supervisor)
#   - ds-ps.sh (process table viewer)
#   - ds-kill.sh (supervisor-aware killer)
#   - supervisor/ state + journal

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"
SUP="$ROOT/supervisor"
STATE="$SUP/state"
LOG="$SUP/log"

mkdir -p "$SCRIPTS" "$SUP" "$STATE" "$LOG"

echo "[DroidShell] Installing Supervisor Suite..."

###############################################
# 1. ds-supervisor.sh
###############################################
cat > "$SCRIPTS/ds-supervisor.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Process Supervisor
# Tracks services, restart policies, and logs.

set -e

ROOT="/sdcard/DroidShell"
SUP="$ROOT/supervisor"
STATE="$SUP/state"
LOG="$SUP/log"
RUNTIME="$ROOT/.runtime"

mkdir -p "$STATE" "$LOG" "$RUNTIME"

TABLE="$STATE/proc-table.tsv"
JOURNAL="$LOG/journal.log"

touch "$TABLE" "$JOURNAL"

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $*" | tee -a "$JOURNAL" >/dev/null
}

start_service() {
    local id="$1"
    local cmd="$2"
    local restart="$3"

    log "[START] id=$id cmd=$cmd restart=$restart"

    # Start process
    bash -c "$cmd" >> "$RUNTIME/$id.log" 2>&1 &
    local pid=$!

    # Record in table: id  pid  restart  cmd
    echo -e "$id\t$pid\t$restart\t$cmd" >> "$TABLE"
}

rebuild_table() {
    # Remove dead entries
    local tmp="$TABLE.tmp"
    : > "$tmp"
    while IFS=$'\t' read -r id pid restart cmd; do
        [ -z "$id" ] && continue
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "$id\t$pid\t$restart\t$cmd" >> "$tmp"
        else
            log "[EXIT] id=$id pid=$pid"
            if [ "$restart" = "always" ] || [ "$restart" = "on-failure" ]; then
                log "[RESTART] id=$id policy=$restart"
                start_service "$id" "$cmd" "$restart"
            fi
        fi
    done < "$TABLE"
    mv "$tmp" "$TABLE"
}

monitor_loop() {
    log "[SUPERVISOR] Starting monitor loop..."
    while true; do
        rebuild_table
        sleep 2
    done
}

case "$1" in
    start)
        monitor_loop
        ;;
    add)
        # ds-supervisor.sh add <id> <restart> <cmd...>
        id="$2"
        restart="$3"
        shift 3
        cmd="$*"
        [ -z "$id" ] && { echo "Usage: ds-supervisor.sh add <id> <restart> <cmd...>"; exit 1; }
        start_service "$id" "$cmd" "$restart"
        ;;
    table)
        cat "$TABLE"
        ;;
    *)
        echo "Usage:"
        echo "  ds-supervisor.sh start              # run supervisor loop"
        echo "  ds-supervisor.sh add <id> <restart> <cmd...>"
        echo "  ds-supervisor.sh table"
        exit 1
        ;;
esac
EOF

chmod +x "$SCRIPTS/ds-supervisor.sh"
echo "[DroidShell] ds-supervisor.sh installed."


###############################################
# 2. ds-ps.sh — process table viewer
###############################################
cat > "$SCRIPTS/ds-ps.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Process Table Viewer (supervisor-aware)

ROOT="/sdcard/DroidShell"
TABLE="$ROOT/supervisor/state/proc-table.tsv"

[ -f "$TABLE" ] || { echo "No supervisor table found."; exit 1; }

printf "%-16s %-8s %-12s %s\n" "ID" "PID" "RESTART" "CMD"
while IFS=$'\t' read -r id pid restart cmd; do
    [ -z "$id" ] && continue
    printf "%-16s %-8s %-12s %s\n" "$id" "$pid" "$restart" "$cmd"
done < "$TABLE"
EOF

chmod +x "$SCRIPTS/ds-ps.sh"
echo "[DroidShell] ds-ps.sh installed."


###############################################
# 3. ds-kill.sh — supervisor-aware killer
###############################################
cat > "$SCRIPTS/ds-kill.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Supervisor-aware Killer
# Kills by id or pid and updates supervisor table.

set -e

ROOT="/sdcard/DroidShell"
TABLE="$ROOT/supervisor/state/proc-table.tsv"

usage() {
    echo "Usage:"
    echo "  ds-kill.sh id <service-id>"
    echo "  ds-kill.sh pid <pid>"
    exit 1
}

cmd="$1"
target="$2"

[ -z "$cmd" ] && usage
[ -z "$target" ] && usage

tmp="$TABLE.tmp"
: > "$tmp"

case "$cmd" in
    id)
        while IFS=$'\t' read -r id pid restart cmdline; do
            [ -z "$id" ] && continue
            if [ "$id" = "$target" ]; then
                echo "[KILL] id=$id pid=$pid"
                kill "$pid" 2>/dev/null || true
            else
                echo -e "$id\t$pid\t$restart\t$cmdline" >> "$tmp"
            fi
        done < "$TABLE"
        mv "$tmp" "$TABLE"
        ;;
    pid)
        while IFS=$'\t' read -r id pid restart cmdline; do
            [ -z "$id" ] && continue
            if [ "$pid" = "$target" ]; then
                echo "[KILL] id=$id pid=$pid"
                kill "$pid" 2>/dev/null || true
            else
                echo -e "$id\t$pid\t$restart\t$cmdline" >> "$tmp"
            fi
        done < "$TABLE"
        mv "$tmp" "$TABLE"
        ;;
    *)
        usage
        ;;
esac
EOF

chmod +x "$SCRIPTS/ds-kill.sh"
echo "[DroidShell] ds-kill.sh installed."


###############################################
# DONE
###############################################
echo "[DroidShell] Supervisor Suite installation complete."
