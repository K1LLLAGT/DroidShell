#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/DroidShell"
cd "$ROOT/scripts"
ls droidshell-* 2>/dev/null && echo "[LINT] Legacy names found." || echo "[LINT] OK"
