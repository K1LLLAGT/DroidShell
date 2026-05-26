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

# Create runtime dirs
mkdir -p "$ROOT/.runtime" "$ROOT/.data"

# Launch isolated shell
PS1="[DroidShell] \\u@\\h:\\w$ " bash --noprofile --norc
