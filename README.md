DROIDSHEDLL – SYSTEM OVERVIEW
=============================

DroidShell is a modular, script-driven automation and diagnostic framework.
It is built around a clean, deterministic ds-* module ecosystem designed for
Android, Linux, embedded systems, and technician-grade workflows.

This README describes the architecture, directory layout, and usage patterns
of the current multi-tier DroidShell system.

------------------------------------------------------------
ARCHITECTURE TIERS
------------------------------------------------------------

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

------------------------------------------------------------
DIRECTORY STRUCTURE
------------------------------------------------------------

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

------------------------------------------------------------
QUICK START
------------------------------------------------------------

Bootstrap the entire system:
  bash scripts/ds-bootstrap-all.sh

Generate module registry:
  bash scripts/ds-module-registry.sh

Run the developer TUI:
  bash scripts/ds-dev-tui.sh

Export the entire environment:
  bash scripts/ds-dist-export.sh

------------------------------------------------------------
PHILOSOPHY
------------------------------------------------------------

DroidShell is built on:
  - Determinism
  - Modularity
  - Reproducibility
  - Transparency
  - Technician-grade tooling

Every script is standalone, auditable, and replaceable.

------------------------------------------------------------
DOCUMENTATION
------------------------------------------------------------

Generate module documentation:
  bash scripts/ds-module-docs.sh

------------------------------------------------------------
LICENSE
------------------------------------------------------------

Choose your preferred license (MIT, Apache 2.0, or proprietary).