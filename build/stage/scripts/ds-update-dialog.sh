#!/usr/bin/env bash
# ds-update-dialog.sh
# Reads update flag and prints dialog instructions.

FLAG=~/.droidshell-update

if [ ! -f "$FLAG" ]; then
  echo "No update check performed yet."
  exit 0
fi

if grep -q "true" "$FLAG"; then
  echo "UPDATE_AVAILABLE"
else
  echo "NO_UPDATE"
fi
