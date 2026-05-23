#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Master Suite Generator
#
#  Purpose:
#    Orchestrates all tier generators and core docs into a single
#    reproducible entrypoint.
#
#  Actions:
#    - Ensures ~/DroidShell and scripts/ exist
#    - Regenerates GIT-SUMMARY.txt and README.txt
#    - Invokes all known ds-generate-*.sh tier generators (if present)
#
#  Usage:
#    bash scripts/ds-generate-master-suite.sh
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"

mkdir -p "$SCRIPTS"

G='\033[1;32m'; Y='\033[1;33m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[MASTER]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
step() { echo -e "\n${M}━━━ $* ━━━${N}"; }

# -----------------------------------------------------------------------------
# 1. Write GIT-SUMMARY.txt
# -----------------------------------------------------------------------------
step "Writing GIT-SUMMARY.txt"

cat > "$ROOT/GIT-SUMMARY.txt" << 'EOF_GITSUM'
DROIDSHELL – GIT CHANGE SUMMARY
===============================

Repository: ~/DroidShell
Branch: main

This file describes the migration from legacy droidshell-* scripts to the
modular ds-* ecosystem.

REMOVED (Legacy droidshell-* scripts)
-------------------------------------
scripts/droidshell-backup-restore.sh
scripts/droidshell-build-release.sh
scripts/droidshell-consolidate.sh
scripts/droidshell-docs-init.sh
scripts/droidshell-etc-init.sh
scripts/droidshell-os.sh
scripts/droidshell-plugin-deploy.sh
scripts/droidshell-plugin-sdk-init.sh
scripts/droidshell-plugin-template.sh
scripts/droidshell-release-zip.sh
scripts/droidshell-sdk-build.sh
scripts/droidshell-setup.sh
scripts/droidshell-site-build.sh
scripts/droidshell-tools-init.sh
ds_layout.txt

MODIFIED
--------
droidshell-tree.txt   (updated to reflect new ds-* ecosystem)

ADDED (New Modular ds-* Architecture)
-------------------------------------
CORE MAINTENANCE:
  ds-cleanup-legacy.sh
  ds-lint-names.sh
  ds-bootstrap-all.sh

MODULE FRAMEWORK:
  ds-module-registry.sh
  ds-module-metadata.sh
  ds-module-tree.sh
  ds-module-docs.sh
  ds-module-search.sh
  ds-module-categories.sh
  ds-module-deps.sh
  ds-module-versioning.sh
  ds-module-installer.sh
  ds-module-sandbox-suite.sh

DISTRIBUTION:
  ds-dist-export.sh
  ds-dist-import.sh
  ds-dist-profile.sh
  ds-dist-preset.sh

DEVELOPER UX:
  ds-dev-tui.sh
  ds-dev-launcher.sh
  ds-dev-help.sh

OBSERVABILITY:
  ds-obs-metrics.sh
  ds-obs-timing.sh
  ds-obs-history.sh
  ds-obs-profiler.sh

POLICY & SAFETY:
  ds-policy-guard.sh
  ds-policy-invariants.sh
  ds-policy-preflight.sh
  ds-policy-rollback.sh

INTEGRITY & AUTO-OPS:
  ds-integrity-snapshot.sh
  ds-integrity-compare.sh
  ds-integrity-daemon.sh
  ds-auto-update.sh
  ds-auto-hardening.sh
  ds-auto-sync.sh

LAB / EXPERIMENTATION:
  ds-lab-snapshot-env.sh
  ds-lab-diff-env.sh
  ds-lab-harness.sh

OPS & CONTROL LAYER:
  ds-ops-queue.sh
  ds-ops-worker.sh
  ds-ops-lock.sh
  ds-ops-unlock.sh
  ds-ops-event-bus.sh
  ds-ops-rotate-snapshots.sh
  ds-ops-rotate-backups.sh

GENERATORS:
  ds-generate-advanced-suite.sh
  ds-generate-module-suite.sh
  ds-generate-next-tier-suite.sh
  ds-generate-next-tier-2-suite.sh
  ds-generate-next-tier-3-suite.sh
  ds-generate-next-tier-4-suite.sh
  ds-generate-next-tier-5-suite.sh
  ds-generate-next-tier-7-suite.sh

RECOMMENDED COMMIT MESSAGE
--------------------------
Massive architecture upgrade: migrated from legacy droidshell-* scripts to full
modular ds-* ecosystem. Added multi-tier maintenance, distribution, observability,
policy, integrity, lab, and ops layers. Removed deprecated scripts. Updated tree.
EOF_GITSUM

log "GIT-SUMMARY.txt written."

# -----------------------------------------------------------------------------
# 2. Write README.txt
# -----------------------------------------------------------------------------
step "Writing README.txt"

cat > "$ROOT/README.txt" << 'EOF_README'
DROIDSHELL – SYSTEM OVERVIEW
============================

DroidShell is a modular, script-driven automation and diagnostic framework.
It is built around a clean, deterministic ds-* module ecosystem designed for
Android, Linux, embedded systems, and technician-grade workflows.

This README describes the architecture, directory layout, and usage patterns
of the current multi-tier DroidShell system.

ARCHITECTURE TIERS
------------------

1. CORE MAINTENANCE
   - Environment bootstrap
   - Naming lint
   - Legacy cleanup

2. MODULE FRAMEWORK
   - Module registry
   - Metadata system
   - Documentation generator
   - Search engine
   - Category classifier
   - Dependency graph
   - Versioning system
   - Installer
   - Sandbox permissions

3. DISTRIBUTION LAYER
   - Export/import
   - Profiles
   - Presets

4. DEVELOPER UX
   - Interactive TUI
   - Fuzzy launcher
   - Help browser

5. OBSERVABILITY
   - Metrics logging
   - Timing analysis
   - History viewer
   - Profiler

6. POLICY & SAFETY
   - Guardrails
   - Invariant checks
   - Preflight checks
   - Rollback

7. INTEGRITY & AUTO-OPS
   - Integrity snapshots
   - Snapshot comparison
   - Integrity daemon
   - Auto-update
   - Auto-hardening
   - Auto-sync

8. LAB / EXPERIMENTATION
   - Environment snapshots
   - Snapshot diff
   - Experiment harness

9. OPS & CONTROL LAYER
   - Job queue
   - Worker engine
   - Locking and unlocking
   - Event bus
   - Snapshot rotation
   - Backup rotation

DIRECTORY STRUCTURE
-------------------

DroidShell/
  scripts/
    ds-*.sh                 (all modular system scripts)
    ds-generate-*.sh        (suite generators)
  registry/
    queue/                  (job queue)
    locks/                  (concurrency locks)
    events/                 (event bus)
    versions/               (module versioning)
    meta/                   (module metadata)
  out/                      (exports, backups, artifacts)
  droidshell-tree.txt       (system tree snapshot)

QUICK START
-----------

Bootstrap the entire system:
  bash scripts/ds-bootstrap-all.sh

Generate module registry:
  bash scripts/ds-module-registry.sh

Run the developer TUI:
  bash scripts/ds-dev-tui.sh

Export the entire environment:
  bash scripts/ds-dist-export.sh

PHILOSOPHY
----------

DroidShell is built on:
  - Determinism
  - Modularity
  - Reproducibility
  - Transparency
  - Technician-grade tooling

Every script is standalone, auditable, and replaceable.

DOCUMENTATION
-------------

Generate module documentation:
  bash scripts/ds-module-docs.sh

LICENSE
-------

Choose your preferred license (MIT, Apache 2.0, or proprietary).
EOF_README

log "README.txt written."

# -----------------------------------------------------------------------------
# 3. Invoke all known tier generators (if present)
# -----------------------------------------------------------------------------
step "Invoking tier generators (if present)"

run_gen() {
  local gen="$1"
  if [[ -x "$SCRIPTS/$gen" ]]; then
    log "Running $gen"
    bash "$SCRIPTS/$gen"
  else
    warn "Generator not found or not executable: $gen"
  fi
}

run_gen ds-generate-module-suite.sh
run_gen ds-generate-advanced-suite.sh
run_gen ds-generate-fix-suite.sh
run_gen ds-generate-next-tier-suite.sh
run_gen ds-generate-next-tier-2-suite.sh
run_gen ds-generate-next-tier-3-suite.sh
run_gen ds-generate-next-tier-4-suite.sh
run_gen ds-generate-next-tier-5-suite.sh
run_gen ds-generate-next-tier-7-suite.sh

step "Master suite generation complete."
log "DroidShell master regeneration finished."
