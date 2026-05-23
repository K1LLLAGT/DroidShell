#!/usr/bin/env bash
# =============================================================================
#  ds-module-categories.sh
#  Auto-categorizes modules based on name patterns and metadata.
#
#  Output:
#    ~/DroidShell/registry/categories.txt
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
REG="$ROOT/registry/categories.txt"

G='\033[1;32m'; N='\033[0m'
log() { echo -e "${G}[CATS]${N} $*"; }

mkdir -p "$(dirname "$REG")"

log "Building category map at: $REG"

{
  echo "# Module Categories"
  echo "# name|category"
  echo "# Generated: $(date)"
  echo ""

  find "$SCRIPTS" -maxdepth 1 -type f -name "ds-*.sh" | sort | while read -r f; do
    name="$(basename "$f")"
    cat="misc"

    case "$name" in
      ds-ecosystem*|ds-bundle-ecosystem*|ds-ecosystem-master.sh)
        cat="ecosystem"
        ;;
      ds-bundle-services*|ds-services*|ds-service-*|ds-service-manager.sh)
        cat="services"
        ;;
      ds-bundle-runtime*|ds-runtime*|ds-os.sh)
        cat="runtime"
        ;;
      ds-root-*|ds_root_*|ds-magisk-*|ds-magisk-*)
        cat="root"
        ;;
      ds-ota-*|ds-update-*|ds-updater-*|ds-qr-install*|ds-qr-installer*)
        cat="ota"
        ;;
      ds-build-*|ds-release-*|ds-sign-*|ds-verify-*|ds-version.sh)
        cat="build-release"
        ;;
      ds-api-*|ds-site-*|ds-docs-*|ds-api-docs.sh|ds-api-server.sh)
        cat="api-web"
        ;;
      ds-plugin-*|ds-sdk-*|ds-sandbox.sh)
        cat="plugins"
        ;;
      ds-health.sh|ds-doctor.sh|ds-system-audit.sh|ds-self-heal.sh|ds-bootstrap-all.sh)
        cat="health"
        ;;
      ds-module-*|ds-generate-*|ds-rename-*|ds-cleanup-*|ds-lint-*|ds-fix-*|ds-bootstrap-*|ds-release-master.sh)
        cat="framework"
        ;;
    esac

    echo "${name}|${cat}"
  done
} > "$REG"

log "Categories written."
