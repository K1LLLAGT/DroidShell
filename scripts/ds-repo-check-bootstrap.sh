#!/usr/bin/env bash
# DroidShell Repository Checker Bootstrap
# Generates:
#   - repo-spec/ canonical structure definition
#   - ds-repo-check.sh (full repository validator)

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"
SPEC="$ROOT/repo-spec"

mkdir -p "$SCRIPTS" "$SPEC"

echo "[DroidShell] Installing Repository Checker..."


###############################################
# 1. Canonical Repo Specification
###############################################
cat > "$SPEC/structure.txt" <<'EOF'
# Canonical DroidShell Repository Structure

/sdcard/DroidShell/
    scripts/
        ds-*.sh
    docs/
        *.md
        man/*.md
    supervisor/
        state/
        log/
    fsdb/
        *.meta
    net/
        *.iface
    etc/
        profile
        services/*.service
    modules/
        <id>/
            module.meta
            module-init.sh
            module-stop.sh
    source/
    tools/
    site/
    sdk/
    .runtime/
    .data/
    .env-registry/
    .pkg-db/
EOF

echo "[DroidShell] repo-spec/structure.txt written."


###############################################
# 2. ds-repo-check.sh — full validator
###############################################
cat > "$SCRIPTS/ds-repo-check.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Repository Checker
# Validates entire repo structure, files, scripts, services, modules, docs.

set -e

ROOT="/sdcard/DroidShell"
SPEC="$ROOT/repo-spec/structure.txt"

echo "[DroidShell] Running Repository Check..."
echo

###############################################
# Helpers
###############################################
ok()   { echo "  [OK]   $1"; }
miss() { echo "  [MISS] $1"; }
bad()  { echo "  [BAD]  $1"; }
info() { echo "  [INFO] $1"; }

###############################################
# 1. Check top-level directories
###############################################
echo "[CHECK] Top-level directories"

dirs=(
    scripts
    docs
    supervisor
    fsdb
    net
    etc
    modules
    source
    tools
    site
    sdk
    .runtime
    .data
    .env-registry
    .pkg-db
)

for d in "${dirs[@]}"; do
    if [ -d "$ROOT/$d" ]; then ok "$d"; else miss "$d"; fi
done

echo


###############################################
# 2. Validate scripts
###############################################
echo "[CHECK] scripts/"

for f in "$ROOT/scripts"/ds-*.sh; do
    [ -f "$f" ] || continue
    if head -n1 "$f" | grep -q "#!/usr/bin/env bash"; then
        ok "$(basename "$f")"
    else
        bad "$(basename "$f") — missing shebang"
    fi
done

echo


###############################################
# 3. Validate services
###############################################
echo "[CHECK] etc/services/*.service"

for svc in "$ROOT/etc/services"/*.service; do
    [ -f "$svc" ] || continue
    id=$(grep '^id=' "$svc" | cut -d= -f2-)
    exec=$(grep '^exec_start=' "$svc" | cut -d= -f2-)

    [ -n "$id" ]   && ok "$(basename "$svc") id=$id"   || bad "$(basename "$svc") missing id"
    [ -n "$exec" ] && ok "$(basename "$svc") exec=$exec" || bad "$(basename "$svc") missing exec_start"

    if [ -n "$exec" ] && [ ! -x "$exec" ]; then
        bad "$(basename "$svc") exec_start not executable: $exec"
    fi
done

echo


###############################################
# 4. Validate modules
###############################################
echo "[CHECK] modules/"

for m in "$ROOT/modules"/*; do
    [ -d "$m" ] || continue
    id=$(basename "$m")

    [ -f "$m/module.meta" ]       && ok "$id/module.meta"       || miss "$id/module.meta"
    [ -f "$m/module-init.sh" ]    && ok "$id/module-init.sh"    || miss "$id/module-init.sh"
    [ -f "$m/module-stop.sh" ]    && ok "$id/module-stop.sh"    || miss "$id/module-stop.sh"
done

echo


###############################################
# 5. Validate docs
###############################################
echo "[CHECK] docs/"

docs=(
    OS-DIRECTORY-SPEC.md
    DEVELOPER-HANDBOOK.md
    RUNTIME-ARCHITECTURE.md
    MANPAGE-INDEX.md
)

for d in "${docs[@]}"; do
    if [ -f "$ROOT/docs/$d" ]; then ok "$d"; else miss "$d"; fi
done

echo "[CHECK] docs/man/*.md"

for man in "$ROOT/docs/man"/*.md; do
    [ -f "$man" ] || continue
    ok "$(basename "$man")"
done

echo


###############################################
# 6. Validate FSDB
###############################################
echo "[CHECK] fsdb/"

for meta in "$ROOT/fsdb"/*.meta; do
    [ -f "$meta" ] || continue
    grep -q '^file=' "$meta"  && ok "$(basename "$meta") file"  || bad "$(basename "$meta") missing file="
    grep -q '^owner=' "$meta" && ok "$(basename "$meta") owner" || bad "$(basename "$meta") missing owner="
done

echo


###############################################
# 7. Validate Networking
###############################################
echo "[CHECK] net/"

for iface in "$ROOT/net"/*.iface; do
    [ -f "$iface" ] || continue
    addr=$(cat "$iface")
    if echo "$addr" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
        ok "$(basename "$iface") $addr"
    else
        bad "$(basename "$iface") invalid address: $addr"
    fi
done

echo


###############################################
# 8. Validate Supervisor
###############################################
echo "[CHECK] supervisor/"

[ -d "$ROOT/supervisor/state" ] && ok "supervisor/state" || miss "supervisor/state"
[ -d "$ROOT/supervisor/log" ]   && ok "supervisor/log"   || miss "supervisor/log"

echo


###############################################
# 9. Validate Init System
###############################################
echo "[CHECK] ds-init.sh"

if [ -x "$ROOT/scripts/ds-init.sh" ]; then
    ok "ds-init.sh"
else
    miss "ds-init.sh"
fi

echo


###############################################
# DONE
###############################################
echo "[DroidShell] Repository Check Complete."
EOF

chmod +x "$SCRIPTS/ds-repo-check.sh"
echo "[DroidShell] ds-repo-check.sh installed."


###############################################
# DONE
###############################################
echo "[DroidShell] Repository Checker installation complete."
