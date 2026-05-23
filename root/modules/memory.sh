#!/usr/bin/env bash
set -euo pipefail
echo "== /proc/meminfo =="
su -c "cat /proc/meminfo"
echo
echo "== /proc/slabinfo =="
su -c "cat /proc/slabinfo"
