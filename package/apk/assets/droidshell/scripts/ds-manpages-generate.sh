#!/usr/bin/env bash
# ds-manpages-generate.sh
# Generate manpage-style text files for each ds-* script based on header comments.

set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
MAN_DIR="$ROOT/docs/man"
mkdir -p "$MAN_DIR"

for f in "$SCRIPTS"/ds-*.sh; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  name="${base%.sh}"
  out="$MAN_DIR/$name.1.txt"

  {
    echo "$name(1)                    DroidShell Manual                    $name(1)"
    echo
    echo "NAME"
    echo "    $name - DroidShell module"
    echo
    echo "SYNOPSIS"
    echo "    $base [options] ..."
    echo
    echo "DESCRIPTION"
    # Take leading comment block as description
    awk '
      BEGIN { in_header=1 }
      {
        if (in_header == 1) {
          if ($0 ~ /^#!/) next
          if ($0 ~ /^#/) {
            sub(/^# ?/, "", $0)
            print "    " $0
          } else {
            in_header=0
          }
        }
      }
    ' "$f"
    echo
    echo "FILES"
    echo "    $f"
    echo
    echo "SEE ALSO"
    echo "    ds-module-registry.sh, ds-module-docs.sh"
    echo
  } > "$out"

  echo "[MAN] $out"
done
