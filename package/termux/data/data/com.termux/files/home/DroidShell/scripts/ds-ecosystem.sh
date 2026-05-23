#!/usr/bin/env bash
# ds-ecosystem.sh
# Orchestrate full DroidShell ecosystem build:
# - Root advanced features
# - Magisk module + overlays
# - Dual build system (root/non-root)
# - Release system (versioning, CI, OTA, channels, signing, deltas)
# - Advanced release (Releases, OTA server, dashboard, nightly, Magisk update, registry)
# - Final build, sign, metadata, Magisk JSON

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

log() { echo "[DroidShell-Ecosystem] $*"; }

log "Base dir: $BASE_DIR"

# Helper: run script if it exists and is executable
run_if_present() {
  local path="$1"
  if [ -x "$path" ]; then
    log "Running: $path"
    "$path"
  else
    log "Skipping (not found or not executable): $path"
  fi
}

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 1: Root advanced + Magisk module"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_if_present "$BASE_DIR/scripts/ds-root-advanced.sh"
run_if_present "$BASE_DIR/scripts/ds-magisk-full.sh"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 2: Dual build system"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_if_present "$BASE_DIR/scripts/ds-dual-system.sh"
run_if_present "$BASE_DIR/scripts/ds-build-dual.sh"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 3: Magisk module build"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_if_present "$BASE_DIR/scripts/build-magisk-droidshell.sh"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 4: Core release system"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_if_present "$BASE_DIR/scripts/ds-release-system.sh"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 5: Advanced release system"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_if_present "$BASE_DIR/scripts/ds-release-advanced.sh"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 6: Version bump (optional patch)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -x "$BASE_DIR/scripts/ds-version.sh" ]; then
  log "Bumping patch version..."
  "$BASE_DIR/scripts/ds-version.sh" patch || log "Version bump failed (continuing)."
else
  log "ds-version.sh not present, skipping version bump."
fi

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 7: Rebuild packages with new version"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_if_present "$BASE_DIR/scripts/ds-build-dual.sh"
run_if_present "$BASE_DIR/scripts/build-magisk-droidshell.sh"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 8: Sign packages + update OTA metadata"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_if_present "$BASE_DIR/scripts/ds-sign-packages.sh"
run_if_present "$BASE_DIR/scripts/ds-ota-metadata.sh"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Stage 9: Sync Magisk update JSON"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_if_present "$BASE_DIR/scripts/ds-magisk-update-sync.sh"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Ecosystem build complete"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " Artifacts:"
log "  - out/droidshell-root.zip"
log "  - out/droidshell-nonroot.zip"
log "  - out/droidshell-magisk-*.zip (if built)"
log " Metadata:"
log "  - ota/metadata.json"
log "  - ota/index.json"
log "  - ota/magisk-update.json"
log " Web:"
log "  - web/installer/index.html"
log "  - web/dashboard/index.html"
log " Registry:"
log "  - registry/index.json"
log
log "Next typical steps:"
log "  git add -A"
log "  git commit -m \"Ecosystem build $(cat VERSION 2>/dev/null || echo)\""
log "  git push"
