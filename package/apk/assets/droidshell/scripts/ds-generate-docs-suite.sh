#!/usr/bin/env bash
# DroidShell Documentation Suite Generator
# Generates:
#   docs/index.md
#   docs/architecture.md
#   docs/modules.md
#   docs/usage.md
#   docs/troubleshooting.md
#   docs/glossary.md
#   docs/changelog/CHANGELOG.md
#   docs/contributing/CONTRIBUTING.md
#   docs/legal/LICENSE

set -euo pipefail

ROOT="$HOME/DroidShell"
DOCS="$ROOT/docs"
CHANGE="$DOCS/changelog"
CONTRIB="$DOCS/contributing"
LEGAL="$DOCS/legal"

mkdir -p "$DOCS" "$CHANGE" "$CONTRIB" "$LEGAL"

echo "[DOCS] Writing index.md"
cat > "$DOCS/index.md" << 'EOF_INDEX'
# DroidShell Documentation

Sections:
- Architecture
- Modules
- Usage
- Troubleshooting
- Glossary
- Changelog
- Contributing
- License
EOF_INDEX

echo "[DOCS] Writing architecture.md"
cat > "$DOCS/architecture.md" << 'EOF_ARCH'
# Architecture Overview

DroidShell is organized into functional tiers:
1. Core Maintenance
2. Module Framework
3. Distribution Layer
4. Developer UX
5. Observability
6. Policy and Safety
7. Integrity and Auto-Ops
8. Lab and Experimentation
9. Ops and Control Layer
EOF_ARCH

echo "[DOCS] Writing modules.md"
cat > "$DOCS/modules.md" << 'EOF_MODULES'
# Module Index
EOF_MODULES

for f in "$ROOT"/scripts/ds-*.sh; do
  base="$(basename "$f")"
  echo "- $base" >> "$DOCS/modules.md"
done

echo "[DOCS] Writing usage.md"
cat > "$DOCS/usage.md" << 'EOF_USAGE'
# Usage Guide

Bootstrap:
  bash scripts/ds-bootstrap-all.sh

Developer TUI:
  bash scripts/ds-dev-tui.sh

Export environment:
  bash scripts/ds-dist-export.sh
EOF_USAGE

echo "[DOCS] Writing troubleshooting.md"
cat > "$DOCS/troubleshooting.md" << 'EOF_TROUBLE'
# Troubleshooting

Regenerate everything:
  bash scripts/ds-generate-master-suite.sh

Fix metadata:
  bash scripts/ds-fix-everything.sh
EOF_TROUBLE

echo "[DOCS] Writing glossary.md"
cat > "$DOCS/glossary.md" << 'EOF_GLOSS'
# Glossary

CAT Generator:
  A script that writes other scripts using heredoc blocks.

Module:
  A standalone ds-* script.

Tier:
  A functional grouping of modules.
EOF_GLOSS

echo "[DOCS] Writing CHANGELOG.md"
cat > "$CHANGE/CHANGELOG.md" << 'EOF_CHANGE'
# CHANGELOG

1.0.0
- Initial modular architecture
- Added documentation suite
EOF_CHANGE

echo "[DOCS] Writing CONTRIBUTING.md"
cat > "$CONTRIB/CONTRIBUTING.md" << 'EOF_CONTRIB'
# Contributing

Code Style:
- Use POSIX Bash
- Use set -euo pipefail

Testing:
  bash scripts/ds-lab-harness.sh label script
EOF_CONTRIB

echo "[DOCS] Writing LICENSE"
cat > "$LEGAL/LICENSE" << 'EOF_LICENSE'
MIT License
EOF_LICENSE

echo "[DOCS] Documentation suite generation complete."
