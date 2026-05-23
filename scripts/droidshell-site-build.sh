#!/data/data/com.termux/files/usr/bin/bash
set -e

DOCS="docs"
SITE="site"

if [ ! -d "$DOCS" ]; then
    echo "[DroidShell] docs/ not found. Run droidshell-docs-init.sh first."
    exit 1
fi

rm -rf "$SITE"
mkdir -p "$SITE"

TEMPLATE_HEAD='<!DOCTYPE html><html><head><meta charset="utf-8"><title>DroidShell</title></head><body>'
TEMPLATE_TAIL='</body></html>'

for f in "$DOCS"/*.md; do
    base=$(basename "$f" .md)
    out="$SITE/$base.html"
    echo "[DroidShell] Rendering $f -> $out"
    {
        echo "$TEMPLATE_HEAD"
        # ultra-simple markdown: # -> <h1>, ## -> <h2>, others as <p>
        while IFS= read -r line; do
            case "$line" in
                \#\#\ * ) echo "<h2>${line#\#\# }</h2>" ;;
                \#\ * )   echo "<h1>${line#\# }</h1>" ;;
                "" )      echo "<br/>" ;;
                * )       echo "<p>$line</p>" ;;
            esac
        done < "$f"
        echo "$TEMPLATE_TAIL"
    } > "$out"
done

echo "[DroidShell] Static site generated in $SITE/"
