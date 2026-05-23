#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"

cmd="${1:-help}"
shift || true

case "$cmd" in
  help)
    cat << EOF
DroidShell CLI

Usage:
  ds help
  ds docs
  ds graphs
  ds serve [port] [watch]
  ds man <module>
  ds search <term>
  ds dash
  ds release [version]
EOF
    ;;
  docs)
    bash "$SCRIPTS/ds-make.sh" docs
    ;;
  graphs)
    bash "$SCRIPTS/ds-make.sh" graphs
    ;;
  serve)
    bash "$SCRIPTS/ds-docs-serve.sh" "${1:-8000}" "${2:-}"
    ;;
  man)
    bash "$SCRIPTS/ds-man.sh" "${1:-}"
    ;;
  search)
    bash "$SCRIPTS/ds-docs-search.sh" "${1:-}"
    ;;
  dash)
    bash "$SCRIPTS/ds-dashboard.sh"
    ;;
  release)
    bash "$SCRIPTS/ds-release.sh" "${1:-}"
    ;;
  *)
    echo "Unknown command: $cmd"
    exit 1
    ;;
esac
