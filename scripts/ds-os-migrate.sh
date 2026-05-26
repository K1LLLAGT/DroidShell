#!/usr/bin/env bash
# DroidShell Unified Migration Script
# Includes:
# 1. Canonical file naming standard
# 2. Git migration plan generator
# 3. Legacy installer cleanup system

set -e

ROOT="/sdcard/DroidShell"
DOCS="$ROOT/docs"
SCRIPTS="$ROOT/scripts"
LEGACY="$ROOT/.legacy"
MIG="$ROOT/MIGRATION.md"

mkdir -p "$DOCS" "$SCRIPTS" "$LEGACY"

echo "[DroidShell] Starting unified OS migration..."

# ---------------------------------------------------------
# 1. CANONICAL FILE NAMING STANDARD
# ---------------------------------------------------------

cat > "$DOCS/NAMING-STANDARD.md" <<'EOF'
# DroidShell Canonical File Naming Standard

## 1. Script Naming
All system scripts follow:

    ds-<component>.sh

Examples:
- ds-root.sh
- ds-vfs.sh
- ds-mod.sh
- ds-service.sh
- ds-os-bootstrap.sh

## 2. Installer Naming
Installers follow:

    install-<target>.sh

Examples:
- install-ds.sh
- install-sdk.sh
- install-mod.sh

## 3. Output Directories
All build outputs follow:

    <name>-out/

Examples:
- droidshell-out/
- release-out/
- sdk-out/

## 4. Metadata Files
Metadata files follow:

    <NAME>.md
    <NAME>.txt

Examples:
- VERSION
- GIT-SUMMARY.md
- ds-tree.txt

## 5. Modules
Modules follow:

    modules/<id>/
        module.meta
        module-init.sh
        module-stop.sh

EOF

echo "[DroidShell] Naming standard written."


# ---------------------------------------------------------
# 2. GIT MIGRATION PLAN GENERATOR
# ---------------------------------------------------------

cat > "$MIG" <<'EOF'
# DroidShell OS Architecture Migration Plan

This document describes the transition from the legacy DroidShell layout
to the new OS‑grade architecture.

## 1. Removed Legacy Files
The following legacy files are deprecated and replaced:

- droidshell-build.sh → ds-build.sh
- droidshell-os-bootstrap.sh → ds-os-bootstrap.sh
- droidshell-tree.txt → ds-tree.txt
- ds-stage0-bootstrap.sh → (merged into ds-os-bootstrap.sh)
- install.sh → install-ds.sh
- ds_root.sh → ds-root.sh

## 2. New Runtime Subsystems
The new OS architecture includes:

- VFS Layer (ds-vfs.sh)
- Service Manager (ds-service.sh)
- Module Loader (ds-mod.sh)
- Unified Boot Pipeline (ds-root.sh boot)

## 3. Git Migration Steps

### Step 1 — Stage all changes
    git add -A

### Step 2 — Review changes
    git status
    git diff

### Step 3 — Commit migration
    git commit -m "Migrate to new DroidShell OS architecture"

### Step 4 — Push to main
    git push

## 4. Rollback Procedure
To revert to the legacy layout:

    git restore .

EOF

echo "[DroidShell] Git migration plan generated."


# ---------------------------------------------------------
# 3. LEGACY INSTALLER CLEANUP SYSTEM
# ---------------------------------------------------------

# List of legacy files to archive
LEGACY_FILES=(
  "droidshell-build.sh"
  "droidshell-os-bootstrap.sh"
  "droidshell-tree.txt"
  "ds-os-layer-installer.sh"
  "ds-os-next-suite-installer.sh"
  "ds-stage0-bootstrap.sh"
  "install.sh"
  "ds_root.sh"
)

echo "[DroidShell] Archiving legacy installers..."

for f in "${LEGACY_FILES[@]}"; do
  if [ -f "$ROOT/$f" ]; then
    mv "$ROOT/$f" "$LEGACY/$f"
    echo "  archived: $f"
  fi
done

cat > "$SCRIPTS/ds-clean-legacy.sh" <<'EOF'
#!/usr/bin/env bash
set -e

ROOT="/sdcard/DroidShell"
LEGACY="$ROOT/.legacy"

echo "[DroidShell] Cleaning legacy installers..."

find "$LEGACY" -type f -print -delete

echo "[DroidShell] Legacy cleanup complete."
EOF

chmod +x "$SCRIPTS/ds-clean-legacy.sh"

echo "[DroidShell] Legacy cleanup system installed."


# ---------------------------------------------------------
# 4. FINAL SUMMARY
# ---------------------------------------------------------

echo "[DroidShell] Unified OS migration complete."
echo "Generated:"
echo "  - docs/NAMING-STANDARD.md"
echo "  - MIGRATION.md"
echo "  - scripts/ds-clean-legacy.sh"
echo "Archived legacy files in: .legacy/"
