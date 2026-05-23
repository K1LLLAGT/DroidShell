#!/usr/bin/env bash
set -euo pipefail
echo "== /proc/sys =="
su -c "ls -R /proc/sys"
echo
echo "== /sys/module =="
su -c "ls -R /sys/module"
