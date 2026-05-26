#!/usr/bin/env bash
# DroidShell Documentation Bootstrap
# Generates:
#   - OS-DIRECTORY-SPEC.md
#   - DEVELOPER-HANDBOOK.md
#   - RUNTIME-ARCHITECTURE.md
#   - Full manpage suite for ds-*.sh
#   - MANPAGE-INDEX.md
#   - Static docs site generator (ds-docs-build.sh)
#   - Developer onboarding script (install-dev.sh)

set -e

ROOT="/sdcard/DroidShell"
DOCS="$ROOT/docs"
MAN="$DOCS/man"
SCRIPTS="$ROOT/scripts"

mkdir -p "$DOCS" "$MAN" "$SCRIPTS"

echo "[DroidShell] Generating documentation suite..."

###############################################
# 1. OS DIRECTORY SPEC
###############################################
cat > "$DOCS/OS-DIRECTORY-SPEC.md" <<'EOF'
# DroidShell OS Directory Specification

Root: /sdcard/DroidShell

## 1. Core Top-Level Layout
- README.md — Overview
- VERSION — Canonical version
- GIT-SUMMARY.md — Git metadata
- ds-root.sh — OS entrypoint
- ds-build.sh — Build system
- install-ds.sh — Installer
- ds-os-bootstrap.sh — OS bootstrap
- ds-tree.txt — Tree snapshot
- .legacy/ — Archived legacy files

## 2. Runtime & State
- .runtime/ — Logs, PIDs, transient data
- .data/ — Persistent OS data

## 3. Documentation
- docs/
  - NAMING-STANDARD.md
  - OS-DIRECTORY-SPEC.md
  - DEVELOPER-HANDBOOK.md
  - RUNTIME-ARCHITECTURE.md
  - man/ — Manpages
  - MANPAGE-INDEX.md

## 4. Scripts
- scripts/
  - ds-vfs.sh
  - ds-service.sh
  - ds-mod.sh
  - ds-clean-legacy.sh
  - ds-os-migrate.sh
  - ds-docs-build.sh
  - install-dev.sh
  - ds-pkg-*.sh

## 5. Services
- services/core/
  - shell.service
  - registry.service
  - ota.service

## 6. Modules
- modules/<id>/
  - module.meta
  - module-init.sh
  - module-stop.sh

## 7. SDK & Site
- sdk/ — Generated SDK artifacts
- site/ — Static documentation site

## 8. Source & Tools
- source/ — Core source
- tools/ — CLI tools

## 9. Desktop & Web
- desktop/ — UI integration
- web/ — Dashboard / web UI

## 10. OTA, Registry, Plugins
- ota/ — OTA metadata
- registry/ — Package registry
- plugins/ — Plugin ecosystem
EOF

echo "[DroidShell] OS-DIRECTORY-SPEC.md written."


###############################################
# 2. DEVELOPER HANDBOOK
###############################################
cat > "$DOCS/DEVELOPER-HANDBOOK.md" <<'EOF'
# DroidShell Developer Handbook

## 1. Setup

Clone the repo:

    cd /sdcard
    git clone <repo-url> DroidShell
    cd DroidShell

Bootstrap:

    bash ds-os-bootstrap.sh
    bash install-ds.sh

## 2. Core Commands

### Boot OS
    bash ds-root.sh boot

### Shell
    bash ds-root.sh shell

### Build
    bash ds-build.sh

Outputs:
- droidshell-out/
- release-out/
- sdk-out/
- site/

## 3. Services

List:
    bash scripts/ds-service.sh list

Start:
    bash scripts/ds-service.sh start

## 4. Modules

List:
    bash scripts/ds-mod.sh list

Init:
    bash scripts/ds-mod.sh init

Stop:
    bash scripts/ds-mod.sh stop

## 5. VFS

Init:
    bash scripts/ds-vfs.sh init

Config:
- vfs/vfs.conf
- vfs/mounts.d/*.mount

## 6. Git Workflow

    git add -A
    git commit -m "Message"
    git push

Migration reference:
- MIGRATION.md
- .legacy/

## 7. CI/CD

Workflow:
- .github/workflows/droidshell-ci.yml

Provides:
- Build + test
- Release bundling
- Artifact upload

## 8. Conventions

- Scripts: ds-<name>.sh
- Installers: install-<target>.sh
- Outputs: <name>-out/
- Modules: modules/<id>/
EOF

echo "[DroidShell] DEVELOPER-HANDBOOK.md written."


###############################################
# 3. RUNTIME ARCHITECTURE DIAGRAM
###############################################
cat > "$DOCS/RUNTIME-ARCHITECTURE.md" <<'EOF'
# DroidShell Runtime Architecture

## 1. Overview

    +---------------------------+
    |       ds-root.sh          |
    |   (boot / shell entry)    |
    +-------------+-------------+
                  |
                  v
    +---------------------------+
    |        VFS Layer          |
    |       ds-vfs.sh           |
    +-------------+-------------+
                  |
                  v
    +---------------------------+
    |      Module Loader        |
    |        ds-mod.sh          |
    +-------------+-------------+
                  |
                  v
    +---------------------------+
    |      Service Manager      |
    |       ds-service.sh       |
    +-------------+-------------+
                  |
                  v
    +---------------------------+
    |   Services & Modules      |
    +---------------------------+

## 2. Boot Sequence

1. ds-root.sh boot  
2. ds-vfs.sh init  
3. ds-mod.sh init  
4. ds-service.sh start  

## 3. Components

### ds-root.sh
- Boot entry
- Shell entry
- Delegates to VFS, modules, services

### VFS Layer
- Defines namespaces
- Ensures directories
- Applies mounts

### Module Loader
- Enumerates modules
- Runs module-init.sh
- Runs module-stop.sh

### Service Manager
- Reads *.service units
- Starts exec_start commands
- Logs to .runtime/<id>.log

## 4. Data Flow

    ds-root.sh boot
      ├─ ds-vfs.sh init
      ├─ ds-mod.sh init
      └─ ds-service.sh start

## 5. Extensibility

- Add services → services/<group>/<id>.service  
- Add modules → modules/<id>/  
- Add mounts → vfs/mounts.d/  
EOF

echo "[DroidShell] RUNTIME-ARCHITECTURE.md written."


###############################################
# 4. MANPAGE SUITE FOR ALL ds-*.sh COMMANDS
###############################################
echo "[DroidShell] Generating manpages..."

for script in "$SCRIPTS"/ds-*.sh; do
    name=$(basename "$script")
    manfile="$MAN/${name%.sh}.1.md"

    cat > "$manfile" <<EOF
# $name — DroidShell Command Manual

## NAME
$name — $(echo "$name" | sed 's/ds-//; s/-/ /g')

## SYNOPSIS
    $name [options]

## DESCRIPTION
This command is part of the DroidShell OS runtime.

## FILES
- /sdcard/DroidShell/scripts/$name

## AUTHOR
DroidShell OS Runtime
EOF

    echo "  - $(basename "$manfile")"
done

echo "[DroidShell] Manpages generated."


###############################################
# 5. MANPAGE INDEX
###############################################
echo "[DroidShell] Generating MANPAGE-INDEX.md..."

OUT="$DOCS/MANPAGE-INDEX.md"

cat > "$OUT" <<'EOF'
# DroidShell Manpage Index

This index lists all available `ds-*.sh` commands and their corresponding manpages.

EOF

for f in $(ls "$MAN"/*.md 2>/dev/null | sort); do
    base=$(basename "$f")
    cmd="${base%.1.md}"
    echo "- **$cmd** — docs/man/$base" >> "$OUT"
done

echo "" >> "$OUT"
echo "Generated automatically by ds-docs-bootstrap.sh." >> "$OUT"

echo "[DroidShell] MANPAGE-INDEX.md written."


###############################################
# 6. STATIC DOCS SITE GENERATOR
###############################################
cat > "$SCRIPTS/ds-docs-build.sh" <<'EOF'
#!/usr/bin/env bash
set -e

ROOT="/sdcard/DroidShell"
DOCS="$ROOT/docs"
SITE="$ROOT/site"

mkdir -p "$SITE"

echo "[DroidShell] Building static documentation site..."

for f in "$DOCS"/*.md "$DOCS"/man/*.md; do
    base=$(basename "$f" .md)
    out="$SITE/$base.html"

    {
        echo "<html><body><pre>"
        sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$f"
        echo "</pre></body></html>"
    } > "$out"

    echo "  - $out"
done

echo "[DroidShell] Static docs site build complete."
EOF

chmod +x "$SCRIPTS/ds-docs-build.sh"
echo "[DroidShell] ds-docs-build.sh installed."


###############################################
# 7. DEVELOPER ONBOARDING SCRIPT
###############################################
cat > "$SCRIPTS/install-dev.sh" <<'EOF'
#!/usr/bin/env bash
set -e

ROOT="/sdcard/DroidShell"

echo "[DroidShell] Developer onboarding starting..."

mkdir -p "$ROOT/.runtime" "$ROOT/.data"

echo "[DroidShell] Installing docs..."
bash "$ROOT/scripts/ds-docs-bootstrap.sh"

echo "[DroidShell] Building docs site..."
bash "$ROOT/scripts/ds-docs-build.sh"

echo "[DroidShell] Developer environment ready."
EOF

chmod +x "$SCRIPTS/install-dev.sh"
echo "[DroidShell] install-dev.sh installed."


###############################################
# DONE
###############################################
echo "[DroidShell] Documentation suite generation complete."
