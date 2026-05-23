#!/usr/bin/env bash
set -euo pipefail
script="${1:-}"; count="${2:-}"; shift 2 || true
[ -z "$script" ] || [ -z "$count" ] && { echo "Usage: ds-obs-profiler.sh <script> <count> [args...]"; exit 1; }
total=0
for i in $(seq 1 "$count"); do
  start=$(date +%s)
  bash "$HOME/DroidShell/scripts/$script" "$@"
  status=$?
  end=$(date +%s)
  dur=$((end-start))
  echo "[PROF] run $i: ${dur}s (status=$status)"
  total=$((total+dur))
done
avg=$((total/count))
echo "[PROF] average: ${avg}s"
