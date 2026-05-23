#!/usr/bin/env bash
set -e

ROOT="/data/data/com.termux/files/home/DroidShell-Build"
REPO="$ROOT/source/DroidShell"

echo "[ds-clean] Cleaning Gradle build artifacts..."

rm -rf "$REPO/.gradle"
rm -rf "$REPO/app/build"
rm -rf "$REPO/build"

echo "[ds-clean] Cleanup complete."
