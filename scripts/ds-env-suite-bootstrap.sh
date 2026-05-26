#!/usr/bin/env bash
# DroidShell Environment Suite Bootstrap
# Generates:
#   - ds-env-doctor.sh
#   - ds-shell.sh
#   - ds-profiled.sh
#   - ds-profiled-install.sh

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"

mkdir -p "$SCRIPTS"

echo "[DroidShell] Installing Environment Suite..."


###############################################
# 1. ds-env-doctor.sh
###############################################
cat > "$SCRIPTS/ds-env-doctor.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Environment Doctor
# Validates PATH, repairs shell configs, checks environment consistency.

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"
ENV_FILE="$ROOT/ds-env.sh"

echo "[DroidShell] Running environment diagnostics..."
echo

# 1. Check ds-env.sh
if [ -f "$ENV_FILE" ]; then
    echo "[OK] ds-env.sh exists"
else
    echo "[ERR] ds-env.sh missing — environment incomplete"
    exit 1
fi

# 2. Check PATH entries
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

# 3. Check shell config integration
echo
echo "[Checking shell configs]"

patch_config() {
    local file="$1"
    [ ! -f "$file" ] && return
    if grep -q "source $ENV_FILE" "$file"; then
        echo "  [OK] $file"
    else
        echo "source $ENV_FILE" >> "$file"
        echo "  [PATCHED] $file"
    fi
}

patch_config "$HOME/.bashrc"
patch_config "$HOME/.profile"
patch_config "$HOME/.zshrc"
patch_config "$HOME/.bash_profile"

echo
echo "[DroidShell] Environment check complete."
echo "PATH now includes:"
echo "$PATH"
EOF

chmod +x "$SCRIPTS/ds-env-doctor.sh"
echo "[DroidShell] ds-env-doctor.sh installed."


###############################################
# 2. ds-shell.sh
###############################################
cat > "$SCRIPTS/ds-shell.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Shell Wrapper
# Launches a clean subshell with isolated DroidShell environment.

set -e

ROOT="/sdcard/DroidShell"
ENV_FILE="$ROOT/ds-env.sh"

echo "[DroidShell] Launching isolated shell..."

# Load environment
# shellcheck disable=SC1090
source "$ENV_FILE"

# Ensure runtime dirs
mkdir -p "$ROOT/.runtime" "$ROOT/.data"

# Launch isolated shell
PS1="[DroidShell] \\u@\\h:\\w$ " bash --noprofile --norc
EOF

chmod +x "$SCRIPTS/ds-shell.sh"
echo "[DroidShell] ds-shell.sh installed."


###############################################
# 3. ds-profiled.sh
###############################################
cat > "$SCRIPTS/ds-profiled.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell profile.d integration
# Ensures ds-env.sh is loaded for all POSIX shells.

ROOT="/sdcard/DroidShell"
ENV_FILE="$ROOT/ds-env.sh"

# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && source "$ENV_FILE"
EOF

chmod +x "$SCRIPTS/ds-profiled.sh"
echo "[DroidShell] ds-profiled.sh installed."


###############################################
# 4. ds-profiled-install.sh
###############################################
cat > "$SCRIPTS/ds-profiled-install.sh" <<'EOF'
#!/usr/bin/env bash
# Installs DroidShell profile.d integration into all shell configs.

set -e

ROOT="/sdcard/DroidShell"
PROF="$ROOT/scripts/ds-profiled.sh"

patch() {
    local file="$1"
    [ ! -f "$file" ] && return
    if grep -q "ds-profiled.sh" "$file"; then
        echo "  [OK] $file already patched"
    else
        echo "source $PROF" >> "$file"
        echo "  [PATCHED] $file"
    fi
}

echo "[DroidShell] Installing profile.d integration..."

patch "$HOME/.profile"
patch "$HOME/.bashrc"
patch "$HOME/.bash_profile"
patch "$HOME/.zshrc"

echo "[DroidShell] profile.d integration complete."
EOF

chmod +x "$SCRIPTS/ds-profiled-install.sh"
echo "[DroidShell] ds-profiled-install.sh installed."


###############################################
# DONE
###############################################
echo "[DroidShell] Environment Suite installation complete."
