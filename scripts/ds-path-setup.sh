#!/usr/bin/env bash
# DroidShell PATH Integration Setup
# Adds canonical PATH entries to all relevant shell configs.

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"
HOME_SCRIPTS="$HOME/DroidShell/scripts"

ENV_FILE="$ROOT/ds-env.sh"

echo "[DroidShell] Setting up PATH integration..."

###############################################
# 1. Create unified environment file
###############################################
cat > "$ENV_FILE" <<EOF
# DroidShell unified environment file

# Canonical DroidShell script paths
export PATH="$SCRIPTS:\$PATH"

# If user keeps a home copy:
[ -d "$HOME_SCRIPTS" ] && export PATH="$HOME_SCRIPTS:\$PATH"
EOF

echo "[DroidShell] Created ds-env.sh"


###############################################
# 2. Function to patch shell config safely
###############################################
patch_shell_config() {
    local file="$1"

    [ ! -f "$file" ] && return 0

    if grep -q "source $ENV_FILE" "$file"; then
        echo "  - Already patched: $file"
    else
        echo "source $ENV_FILE" >> "$file"
        echo "  - Patched: $file"
    fi
}

###############################################
# 3. Patch all relevant shell configs
###############################################
echo "[DroidShell] Patching shell configs..."

patch_shell_config "$HOME/.bashrc"
patch_shell_config "$HOME/.profile"
patch_shell_config "$HOME/.zshrc"
patch_shell_config "$HOME/.bash_profile"

###############################################
# 4. Immediate activation
###############################################
echo "[DroidShell] Activating environment..."
# shellcheck disable=SC1090
source "$ENV_FILE"

echo "[DroidShell] PATH integration complete."
echo "Current PATH:"
echo "$PATH"
