#!/usr/bin/env bash
set -euo pipefail
echo "== /proc/sched_debug =="
su -c "cat /proc/sched_debug"
echo
echo "== CPU sysfs =="
su -c "ls -R /sys/devices/system/cpu"
