#!/usr/bin/env bash
set -euo pipefail
echo "== thermal =="
su -c "ls -R /sys/class/thermal"
echo
echo "== power_supply =="
su -c "ls -R /sys/class/power_supply"
