#!/usr/bin/env bash
set -e

ACT="app/src/main/java/com/termux/app/TermuxActivity.java"
IDS="app/src/main/res/values/ids.xml"

echo "[DroidShell] Applying Java menu injector..."

# ---------------------------------------------------------
# 1. Ensure ids.xml exists and contains action_droidshell_tools
# ---------------------------------------------------------
if [ ! -f "$IDS" ]; then
    echo "[DroidShell] Creating ids.xml..."
    mkdir -p "$(dirname "$IDS")"
    cat > "$IDS" << 'EOIDS'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <item name="action_droidshell_tools" type="id"/>
</resources>
EOIDS
else
    if ! grep -q "action_droidshell_tools" "$IDS"; then
        echo "[DroidShell] Adding ID to ids.xml..."
        sed -i 's#</resources>#    <item name="action_droidshell_tools" type="id"/>\n</resources>#' "$IDS"
    fi
fi

# ---------------------------------------------------------
# 2. Inject menu item into onCreateOptionsMenu
# ---------------------------------------------------------
if ! grep -q "action_droidshell_tools" "$ACT"; then
    echo "[DroidShell] Injecting menu item into onCreateOptionsMenu..."
    sed -i '/onCreateOptionsMenu(Menu menu)/,/return super.onCreateOptionsMenu(menu);/{
        /return super.onCreateOptionsMenu(menu);/i \
        // DroidShell Tools menu item (idempotent)\
        if (menu.findItem(R.id.action_droidshell_tools) == null) {\
            menu.add(0, R.id.action_droidshell_tools, 0, "DroidShell Tools");\
        }
    }' "$ACT"
else
    echo "[DroidShell] Menu item already present — skipping."
fi

# ---------------------------------------------------------
# 3. Inject handler into onContextItemSelected
# ---------------------------------------------------------
if grep -q "onContextItemSelected(MenuItem item)" "$ACT"; then
    if ! grep -q "showDroidShellTools()" "$ACT"; then
        echo "[DroidShell] Injecting handler into onContextItemSelected..."
        sed -i '/onContextItemSelected(MenuItem item)/,/return super.onContextItemSelected(item);/{
            /int id = item.getItemId();/a \
        // Handle DroidShell Tools\
        if (id == R.id.action_droidshell_tools) {\
            showDroidShellTools();\
            return true;\
        }
        }' "$ACT"
    else
        echo "[DroidShell] Handler already present — skipping."
    fi
else
    echo "[DroidShell] WARNING: onContextItemSelected not found — cannot inject handler."
fi

echo "[DroidShell] Java menu injector complete."
