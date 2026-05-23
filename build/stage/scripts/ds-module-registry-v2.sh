#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/DroidShell"
SCRIPTS="$ROOT/scripts"
REG="$ROOT/registry/modules"
mkdir -p "$REG"

OUT_JSON="$REG/modules.json"

echo "[" > "$OUT_JSON"
first=1
for f in "$SCRIPTS"/ds-*.sh; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  deps_line="$(grep -E '^# DEPS:' "$f" || true)"
  cat_line="$(grep -E '^# CAT:' "$f" || true)"
  cat "${f}" | head -n 1 >/dev/null 2>&1 || true

  deps=""
  [ -n "$deps_line" ] && deps="${deps_line#\# DEPS: }"
  catg=""
  [ -n "$cat_line" ] && catg="${cat_line#\# CAT: }"

  [ "$first" -eq 0 ] && echo "," >> "$OUT_JSON"
  first=0

  printf '  {"name":"%s","path":"%s","deps":[' "$base" "$f" >> "$OUT_JSON"
  dfirst=1
  for d in $deps; do
    [ "$dfirst" -eq 0 ] && printf ',' >> "$OUT_JSON"
    dfirst=0
    printf '"%s"' "$d" >> "$OUT_JSON"
  done
  printf '],"category":"%s"}' "$catg" >> "$OUT_JSON"
done
echo >> "$OUT_JSON"
echo "]" >> "$OUT_JSON"

echo "[REGV2] Wrote $OUT_JSON"
