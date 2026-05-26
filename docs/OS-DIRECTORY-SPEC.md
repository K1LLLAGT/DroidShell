# DroidShell OS Directory Specification

Root: `/sdcard/DroidShell`

## 1. Core Top-Level Layout

- `/sdcard/DroidShell/`
  - `README.md` — Project overview
  - `VERSION` — Canonical version string
  - `GIT-SUMMARY.md` — Generated Git metadata
  - `ds-root.sh` — Primary OS entrypoint
  - `ds-build.sh` — Top-level build script
  - `install-ds.sh` — Primary installer
  - `ds-os-bootstrap.sh` — OS bootstrap / stage0+
  - `ds-tree.txt` — Canonical tree snapshot
  - `.legacy/` — Archived legacy scripts (not tracked)

## 2. Runtime & State

- `.runtime/`
  - Service logs, PID files, transient runtime data
  - Example:
    - `.runtime/shell.log`
    - `.runtime/registry.log`
- `.data/`
  - Persistent OS data (registries, caches, indexes)
  - Safe to back up, not auto-regenerated

## 3. Configuration & Docs

- `docs/`
  - `NAMING-STANDARD.md` — File naming conventions
  - `OS-DIRECTORY-SPEC.md` — This document
  - `DEVELOPER-HANDBOOK.md` — Developer workflow
  - `RUNTIME-ARCHITECTURE.md` — Runtime diagram & explanation

## 4. Scripts

- `scripts/`
  - `ds-vfs.sh` — VFS initialization and mount simulation
  - `ds-service.sh` — Service manager
  - `ds-mod.sh` — Module loader
  - `ds-os-migrate.sh` — OS migration helper
  - `ds-clean-legacy.sh` — Legacy cleanup
  - `ds-pkg-*.sh` — Package manager tools
  - `ds-*.sh` — All OS-level utilities follow `ds-<component>.sh`

## 5. Services

- `services/`
  - `core/`
    - `shell.service` — Interactive shell service unit
    - `registry.service` — Package registry service unit
    - `ota.service` — OTA updater service unit

Service unit format:

- `id=<id>`
- `description=<text>`
- `after=<comma-separated ids>`
- `wants=<comma-separated ids>`
- `restart=<policy>`
- `exec_start=<command>`

## 6. Modules

- `modules/`
  - `<module-id>/`
    - `module.meta` — Metadata (id, version, description, requires, after)
    - `module-init.sh` — Init hook
    - `module-stop.sh` — Stop hook

Example:

- `modules/example-module/`
  - `module.meta`
  - `module-init.sh`
  - `module-stop.sh`

## 7. SDK & Site

- `sdk/`
  - Generated SDK artifacts (APIs, headers, client libs)
- `site/`
  - Static documentation site output (HTML, assets)

## 8. Source & Tools

- `source/`
  - Core source code (shell, helpers, libraries)
- `tools/`
  - CLI tools, helper binaries, wrappers

## 9. Desktop & Web

- `desktop/`
  - Desktop UI integration, launchers, shortcuts
- `web/`
  - Web UI / dashboard, HTTP frontends

## 10. OTA, Registry, Plugins

- `ota/`
  - OTA metadata, manifests, update scripts
- `registry/`
  - Package registry data, indexes, manifests
- `plugins/`
  - Plugin ecosystem (user-facing extensions)
