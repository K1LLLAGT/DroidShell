#!/usr/bin/env bash
# DroidShell profile.d integration
# Ensures ds-env.sh is loaded for all POSIX shells.

ROOT="/sdcard/DroidShell"
ENV_FILE="$ROOT/ds-env.sh"

# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && source "$ENV_FILE"
