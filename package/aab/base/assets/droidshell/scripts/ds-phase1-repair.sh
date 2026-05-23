#!/usr/bin/env bash
set -e

REPO="/data/data/com.termux/files/home/DroidShell-Build/source/DroidShell"
STRINGS="$REPO/app/src/main/res/values/strings.xml"
ACT="$REPO/app/src/main/java/com/termux/app/TermuxActivity.java"

echo "[repair] Fixing strings.xml..."

# 1. Backup
cp "$STRINGS" "$STRINGS.bak"

# 2. Remove everything AFTER </resources>
sed -i '1h;1!H;$!d; s#</resources>.*#</resources>#' "$STRINGS"

# 3. Reinsert DroidShell footer safely BEFORE </resources>
if ! grep -q "about_droidshell_footer" "$STRINGS"; then
    sed -i '/<\/resources>/i \
    <string name="about_droidshell_footer">DroidShell — Android Terminal Emulator. Enhanced automation, startup hooks, and developer tooling.</string>' "$STRINGS"
fi

echo "[repair] strings.xml repaired."

# ---------------------------------------------------------
# Reinforce menu injector (robust signature-based)
# ---------------------------------------------------------

echo "[repair] Reinforcing menu injection..."

# 4. Insert menu item if missing
if ! grep -q "action_droidshell_tools" "$ACT"; then
    sed -i '/public boolean onCreateOptionsMenu/,/}/{
        /Menu menu/ a \
        // DroidShell Tools menu item (idempotent)\
        if (menu.findItem(R.id.action_droidshell_tools) == null) menu.add(0, R.id.action_droidshell_tools, 0, "DroidShell Tools");
    }' "$ACT"
fi

# 5. Ensure handler exists
if grep -q "onContextItemSelected" "$ACT"; then
    if ! grep -q "showDroidShellTools()" "$ACT"; then
        sed -i '/onContextItemSelected/,/return/{
            /int id = item.getItemId()/ a \
            if (id == R.id.action_droidshell_tools) { showDroidShellTools(); return true; }
        }' "$ACT"
    fi
fi

echo "[repair] Menu injection reinforced."
echo "[repair] Phase 1 repair complete."
