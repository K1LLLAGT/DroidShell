#!/usr/bin/env bash
# droidshell-os-bootstrap.sh
# One-shot script to lay down VFS, Service Manager, Module Loader, and ds_root wiring.

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"
SERVICES="$ROOT/services"
MODULES="$ROOT/modules"
VFS="$ROOT/vfs"

echo "[DroidShell] Laying out OS runtime (VFS, services, modules)..."

mkdir -p "$SCRIPTS" "$SERVICES/core" "$MODULES/example-module" "$VFS/mounts.d" "$ROOT/.runtime" "$ROOT/.data"

# ---------------------------
# VFS CONFIG + MOUNTS + SCRIPT
# ---------------------------

cat > "$VFS/vfs.conf" <<'EOF'
# VFS root namespaces
VFS_ROOT="/sdcard/DroidShell"
VFS_DATA="$VFS_ROOT/.data"
VFS_RUNTIME="$VFS_ROOT/.runtime"
VFS_MODULES="$VFS_ROOT/modules"
VFS_SERVICES="$VFS_ROOT/services"
EOF

cat > "$VFS/mounts.d/10-core.mount" <<'EOF'
name=core
src=/sdcard/DroidShell
dst=/sdcard/DroidShell/.runtime/core
type=bind
EOF

cat > "$VFS/mounts.d/20-modules.mount" <<'EOF'
name=modules
src=/sdcard/DroidShell/modules
dst=/sdcard/DroidShell/.runtime/modules
type=bind
EOF

cat > "$SCRIPTS/ds-vfs.sh" <<'EOF'
#!/usr/bin/env bash
set -e

VFS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/vfs"
. "$VFS_ROOT/vfs.conf"

log() { echo "[VFS] $*"; }

ensure_dirs() {
  mkdir -p "$VFS_DATA" "$VFS_RUNTIME" "$VFS_MODULES" "$VFS_SERVICES"
}

apply_mounts() {
  for f in "$VFS_ROOT"/mounts.d/*.mount; do
    [ -f "$f" ] || continue
    name=$(grep '^name=' "$f" | cut -d= -f2-)
    src=$(grep '^src=' "$f" | cut -d= -f2-)
    dst=$(grep '^dst=' "$f" | cut -d= -f2-)
    type=$(grep '^type=' "$f" | cut -d= -f2-)

    [ -z "$name" ] && continue
    mkdir -p "$src" "$dst"

    case "$type" in
      bind)
        log "mount $name: $src -> $dst (bind, simulated)"
        # On Android/Termux we often fake bind by just using the path;
        # real mount requires root. For now, we just ensure dirs exist.
        ;;
      *)
        log "unknown mount type '$type' for $name, skipping"
        ;;
    esac
  done
}

case "$1" in
  init)
    ensure_dirs
    apply_mounts
    ;;
  *)
    echo "Usage: ds-vfs.sh init"
    exit 1
    ;;
esac
EOF

chmod +x "$SCRIPTS/ds-vfs.sh"

# ---------------------------
# SERVICE UNITS + MANAGER
# ---------------------------

cat > "$SERVICES/core/shell.service" <<'EOF'
id=shell
description=DroidShell interactive shell
after=registry
wants=registry
restart=on-failure
exec_start=/sdcard/DroidShell/ds_root.sh shell
EOF

cat > "$SERVICES/core/registry.service" <<'EOF'
id=registry
description=DroidShell package registry
after=
wants=
restart=always
exec_start=/sdcard/DroidShell/scripts/ds-pkg-registry.sh
EOF

cat > "$SERVICES/core/ota.service" <<'EOF'
id=ota
description=DroidShell OTA updater
after=registry
wants=registry
restart=on-failure
exec_start=/sdcard/DroidShell/scripts/ds-ota.sh
EOF

cat > "$SCRIPTS/ds-service.sh" <<'EOF'
#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICES_DIR="$ROOT/services"
RUNTIME_DIR="$ROOT/.runtime"

log() { echo "[svc] $*"; }

parse_unit() {
  local file="$1" key="$2"
  grep "^$key=" "$file" | head -n1 | cut -d= -f2-
}

list_units() {
  find "$SERVICES_DIR" -type f -name '*.service' | sort
}

start_unit() {
  local file="$1"
  local id desc after wants restart exec_start
  id=$(parse_unit "$file" id)
  desc=$(parse_unit "$file" description)
  after=$(parse_unit "$file" after)
  wants=$(parse_unit "$file" wants)
  restart=$(parse_unit "$file" restart)
  exec_start=$(parse_unit "$file" exec_start)

  [ -z "$id" ] && return 0
  log "starting [$id] - $desc"
  mkdir -p "$RUNTIME_DIR"
  nohup sh -c "$exec_start" >"$RUNTIME_DIR/$id.log" 2>&1 &
}

start_all() {
  for f in $(list_units); do
    start_unit "$f"
  done
}

case "$1" in
  start)
    start_all
    ;;
  list)
    list_units
    ;;
  *)
    echo "Usage: ds-service.sh {start|list}"
    exit 1
    ;;
esac
EOF

chmod +x "$SCRIPTS/ds-service.sh"

# ---------------------------
# MODULE EXAMPLE + LOADER
# ---------------------------

cat > "$MODULES/example-module/module.meta" <<'EOF'
id=example-module
version=1.0.0
description=Example DroidShell module
requires=
after=
EOF

cat > "$MODULES/example-module/module-init.sh" <<'EOF'
#!/usr/bin/env bash
echo "[module:example] init"
# put module-specific setup here
EOF

cat > "$MODULES/example-module/module-stop.sh" <<'EOF'
#!/usr/bin/env bash
echo "[module:example] stop"
# cleanup here
EOF

chmod +x "$MODULES/example-module/module-init.sh" "$MODULES/example-module/module-stop.sh"

cat > "$SCRIPTS/ds-mod.sh" <<'EOF'
#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULES_DIR="$ROOT/modules"

log() { echo "[mod] $*"; }

list_modules() {
  find "$MODULES_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort
}

load_meta() {
  local mod="$1" key="$2"
  local file="$MODULES_DIR/$mod/module.meta"
  [ -f "$file" ] || return 0
  grep "^$key=" "$file" | head -n1 | cut -d= -f2-
}

init_module() {
  local mod="$1"
  local init="$MODULES_DIR/$mod/module-init.sh"
  [ -x "$init" ] || return 0
  log "init $mod"
  "$init"
}

stop_module() {
  local mod="$1"
  local stop="$MODULES_DIR/$mod/module-stop.sh"
  [ -x "$stop" ] || return 0
  log "stop $mod"
  "$stop"
}

init_all() {
  for m in $(list_modules); do
    init_module "$m"
  done
}

stop_all() {
  for m in $(list_modules); do
    stop_module "$m"
  done
}

case "$1" in
  list)
    list_modules
    ;;
  init)
    init_all
    ;;
  stop)
    stop_all
    ;;
  *)
    echo "Usage: ds-mod.sh {list|init|stop}"
    exit 1
    ;;
esac
EOF

chmod +x "$SCRIPTS/ds-mod.sh"

# ---------------------------
# PATCH ds_root.sh (if present)
# ---------------------------

if [ -f "$ROOT/ds_root.sh" ]; then
  echo "[DroidShell] Patching ds_root.sh boot entry (non-destructive append)..."
  cat >> "$ROOT/ds_root.sh" <<'EOF'

# --- DroidShell OS boot wiring (VFS + modules + services) ---
if [ "$1" = "boot" ]; then
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  bash "$ROOT/scripts/ds-vfs.sh" init
  bash "$ROOT/scripts/ds-mod.sh" init
  bash "$ROOT/scripts/ds-service.sh" start
  echo "[DroidShell] boot complete"
  exit 0
fi
EOF
else
  echo "[DroidShell] WARNING: ds_root.sh not found, skipping boot wiring."
fi

echo "[DroidShell] OS runtime layout complete."
