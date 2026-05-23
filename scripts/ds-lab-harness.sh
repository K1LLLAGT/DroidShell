#!/usr/bin/env bash
# =============================================================================
#  ds-lab-harness.sh
#  Simple experiment harness: run a script under timing + telemetry + crash log.
#
#  Usage:
#    ds-lab-harness.sh <label> <script> [args...]
# =============================================================================

set -euo pipefail

ROOT="$HOME/DroidShell"

label="${1:-}"; shift || true
script="${1:-}"; shift || true

[[ -z "$label" || -z "$script" ]] && {
  echo "Usage: ds-lab-harness.sh <label> <script> [args...]"
  exit 1
}

"$ROOT/scripts/ds-telemetry-log.sh" "lab-start" label="$label" script="$script"
"$ROOT/scripts/ds-obs-timing.sh" "$script" "$@" || {
  "$ROOT/scripts/ds-crash-log.sh" "$script" "$@"
  "$ROOT/scripts/ds-telemetry-log.sh" "lab-fail" label="$label" script="$script"
  exit 1
}
"$ROOT/scripts/ds-telemetry-log.sh" "lab-success" label="$label" script="$script"
