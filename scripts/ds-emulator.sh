#!/usr/bin/env bash
set -e

$ANDROID_HOME/emulator/emulator \
  -avd DroidShell-API34 \
  -no-window \
  -no-audio \
  -gpu swiftshader_indirect \
  -no-snapshot \
  -wipe-data
