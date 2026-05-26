#!/usr/bin/env bash
# DroidShell Environment Doctor
# Validates PATH, repairs shell configs, checks environment consistency.

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"
ENV_FILE="$ROOT/ds-env.sh"

echo "[DroidShell] Running environment diagnostics..."
echo

###############################################
# 1. Check ds-env.sh
###############################################
if [ -f "$ENV_FILE" ]; then
    echo "[OK] ds-env.sh exists"
else
    echo "[ERR] ds-env.sh missing — environment incomplete"
    exit 1
fi

###############################################
# 2. Check PATH entries
###############################################
echo
echo "[Checking PATH]"

check_path() {
    local p="$1"
    if echo "$PATH" | tr ':' '\n' | grep -qx "$p"; then
        echo "  [OK] $p"
    else
        echo "  [MISS] $p"
    fi
}

check_path "$SCRIPTS"
check_path "$HOME/DroidShell/scripts"

###############################################
# 3. Check shell config integration
###############################################
echo
echo "[Checking shell configs]"

check_config() {
    local file="$1"
    if [ -f "$file" ]; then
        if grep -q "source $ENV_FILE" "$file"; then
            echo "  [OK] $file"
        else
            echo "  [MISS] $file — patching..."
            echo "source $ENV_FILE" >> "$file"
        fi
    fi
}

check_config "$HOME/.bashrc"
check_config "$HOME/.profile"
check_config "$HOME/.zshrc"
check_config "$HOME/.bash_profile"

###############################################
# 4. Final summary
###############################################
echo
echo "[DroidShell] Environment check complete."
echo "PATH now includes:"
echo "$PATH"
