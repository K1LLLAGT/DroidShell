#!/usr/bin/env bash
set -e

DOCS="docs"
SITE="site"

[ ! -d "$DOCS" ] && echo "[DroidShell] docs/ missing" && exit 1

rm -rf "$SITE"
mkdir -p "$SITE"

HEAD='<!DOCTYPE html><html><head><meta charset="utf-8"><title>DroidShell</title></head><body>'
TAIL='</body></html>'

for f in "$DOCS"/*.md; do
    base=$(basename "$f" .md)
    out="$SITE/$base.html"
    echo "[DroidShell] Rendering $f → $out"

    {
        echo "$HEAD"
        while IFS= read -r line; do
            case "$line" in
                \#\#\ * ) echo "<h2>${line#\#\# }</h2>" ;;
                \#\ * )   echo "<h1>${line#\# }</h1>" ;;
                "" )      echo "<br/>" ;;
                * )       echo "<p>$line</p>" ;;
            esac
        done < "$f"
        echo "$TAIL"
    } > "$out"
done

echo "[DroidShell] Static site generated in $SITE/"
