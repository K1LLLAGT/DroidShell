#!/usr/bin/env bash
set -euo pipefail
echo "== /dev/block =="
su -c "ls -R /dev/block"
echo
echo "== /proc/partitions =="
su -c "cat /proc/partitions"
