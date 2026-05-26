#!/usr/bin/env bash
set -e

echo "[DroidShell] Initializing build pipeline..."

chmod +x scripts/ds-*.sh

mkdir -p droidshell-out release-out sdk-out site workspace

echo "[DroidShell] Build pipeline ready."
