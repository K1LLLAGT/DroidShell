#!/usr/bin/env bash
# =============================================================================
#  DroidShell — Script Renamer
#  Converts all legacy droidshell-*.sh scripts → ds-*.sh
#
#  Safe, idempotent, reversible.
# =============================================================================

set -euo pipefail

BASE_DIR="$HOME/DroidShell/scripts"
BACKUP_FILE="$BASE_DIR/renamed-droidshell-scripts.log"

G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; M='\033[1;35m'; N='\033[0m'
log()  { echo -e "${G}[RENAME]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N}   $*"; }
err()  { echo -e "${R}[ERR]${N}    $*"; }

echo -e "${M}━━━ DroidShell Script Renamer ━━━${N}"
echo "Scanning for legacy droidshell-*.sh scripts…"
echo ""

cd "$BASE_DIR"

# Find all scripts starting with droidshell-
mapfile -t FILES < <(find "$BASE_DIR" -maxdepth 1 -type f -name "droidshell-*.sh" | sort)

if [[ ${#FILES[@]} -eq 0 ]]; then
  warn "No droidshell-*.sh scripts found — nothing to rename"
  exit 0
fi

echo "Backup log: $BACKUP_FILE"
echo "# Renamed scripts — $(date)" > "$BACKUP_FILE"

for OLD in "${FILES[@]}"; do
  NAME="$(basename "$OLD")"
  BASE="${NAME#droidshell-}"        # remove prefix
  NEW="ds-${BASE}"

  # Avoid renaming if target already exists
  if [[ -f "$BASE_DIR/$NEW" ]]; then
    warn "Skipping $NAME → $NEW (already exists)"
    continue
  fi

  log "Renaming: $NAME → $NEW"
  mv "$OLD" "$BASE_DIR/$NEW"

  # Fix internal references inside the renamed script
  sed -i \
    -e 's/droidshell-/ds-/g' \
    -e 's/DroidShell-/DS-/g' \
    "$BASE_DIR/$NEW"

  chmod +x "$BASE_DIR/$NEW"

  echo "$NAME → $NEW" >> "$BACKUP_FILE"
done

echo ""
echo -e "${G}All renames complete.${N}"
echo "Backup log written to: $BACKUP_FILE"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
