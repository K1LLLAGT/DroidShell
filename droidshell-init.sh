#!/usr/bin/env bash
set -e

# -----------------------------------------
# ABSOLUTE PATHS
# -----------------------------------------
ROOT="/data/data/com.termux/files/home/DroidShell-Build"
SRC="$ROOT/source"
REPO="$SRC/DroidShell"

APP_ID="com.droidshell.app"
APP_NAME="DroidShell"
REPO_URL="https://github.com/termux/termux-app.git"

NO_CLONE=0
[ "$1" = "--no-clone" ] && NO_CLONE=1

echo "[DroidShell] Initializing project..."
echo "[DroidShell] ROOT: $ROOT"
echo "[DroidShell] REPO: $REPO"

# -----------------------------------------
# CLONE OR REUSE EXISTING REPO
# -----------------------------------------
if [ -d "$REPO/.git" ]; then
    echo "[DroidShell] Repo exists — using existing source."
else
    if [ "$NO_CLONE" -eq 1 ]; then
        echo "[DroidShell] --no-clone used but repo missing. Aborting."
        exit 1
    fi
    echo "[DroidShell] Cloning termux-app..."
    git clone "$REPO_URL" "$REPO"
fi

cd "$REPO"

# -----------------------------------------
# BASIC PATCHES
# -----------------------------------------
echo "[DroidShell] Applying patches..."

# 1. applicationId + versionName
sed -i "s/applicationId \"com.termux\"/applicationId \"$APP_ID\"/g" app/build.gradle
sed -i "s/versionName \".*\"/versionName \"0.119.0-droidshell\"/g" app/build.gradle

# 2. App name
sed -i "s/<string name=\"app_name\">.*<\/string>/<string name=\"app_name\">$APP_NAME<\/string>/g" \
    app/src/main/res/values/strings.xml

# 3. About footer (idempotent)
if ! grep -q "about_droidshell_footer" app/src/main/res/values/strings.xml; then
cat >> app/src/main/res/values/strings.xml << 'EOABOUT'
<string name="about_droidshell_footer">
DroidShell — Android Terminal Emulator. Enhanced automation, startup hooks, and developer tooling.
</string>
EOABOUT
fi

# -----------------------------------------
# JAVA MENU INJECTOR (MERGED)
# -----------------------------------------
TERMUX_ACTIVITY="app/src/main/java/com/termux/app/TermuxActivity.java"
IDS_XML="app/src/main/res/values/ids.xml"

echo "[DroidShell] Injecting Java menu hooks..."

# 1. Ensure ids.xml exists
if [ ! -f "$IDS_XML" ]; then
    mkdir -p "$(dirname "$IDS_XML")"
    cat > "$IDS_XML" << 'EOIDS'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <item name="action_droidshell_tools" type="id"/>
</resources>
EOIDS
else
    if ! grep -q "action_droidshell_tools" "$IDS_XML"; then
        sed -i 's#</resources>#    <item name="action_droidshell_tools" type="id"/>\n</resources>#' "$IDS_XML"
    fi
fi

# 2. Inject menu item into onCreateOptionsMenu
if ! grep -q "action_droidshell_tools" "$TERMUX_ACTIVITY"; then
    echo "[DroidShell] Injecting menu item into onCreateOptionsMenu..."
    sed -i '/onCreateOptionsMenu(Menu menu)/,/return super.onCreateOptionsMenu(menu);/{
        /return super.onCreateOptionsMenu(menu);/i \
        // DroidShell Tools menu item (idempotent)\
        if (menu.findItem(R.id.action_droidshell_tools) == null) {\
            menu.add(0, R.id.action_droidshell_tools, 0, "DroidShell Tools");\
        }
    }' "$TERMUX_ACTIVITY"
else
    echo "[DroidShell] Menu item already present — skipping."
fi

# 3. Inject handler into onContextItemSelected
if grep -q "onContextItemSelected(MenuItem item)" "$TERMUX_ACTIVITY"; then
    if ! grep -q "showDroidShellTools()" "$TERMUX_ACTIVITY"; then
        echo "[DroidShell] Injecting handler into onContextItemSelected..."
        sed -i '/onContextItemSelected(MenuItem item)/,/return super.onContextItemSelected(item);/{
            /int id = item.getItemId();/a \
        // Handle DroidShell Tools\
        if (id == R.id.action_droidshell_tools) {\
            showDroidShellTools();\
            return true;\
        }
        }' "$TERMUX_ACTIVITY"
    else
        echo "[DroidShell] Handler already present — skipping."
    fi
else
    echo "[DroidShell] WARNING: onContextItemSelected not found — cannot inject handler."
fi

# -----------------------------------------
# STARTUP + TOOLS METHODS
# -----------------------------------------
if ! grep -q "runDroidShellStartupScript" "$TERMUX_ACTIVITY"; then
    sed -i '/Logger.logDebug(LOG_TAG, "onCreate");/a \        runDroidShellStartupScript();' "$TERMUX_ACTIVITY"
fi

if ! grep -q "showDroidShellTools" "$TERMUX_ACTIVITY"; then
cat >> "$TERMUX_ACTIVITY" << 'EOCODE'

    private void runDroidShellStartupScript() {
        try {
            String home = TermuxConstants.TERMUX_HOME_DIR_PATH;
            java.io.File script = new java.io.File(home, ".droidshell-startup");
            if (!script.exists() || !script.canExecute()) return;
            String cmd = script.getAbsolutePath();
            TermuxSessionActivity.startShellSession(this, cmd, null);
        } catch (Exception e) {
            android.widget.Toast.makeText(this, "DroidShell startup failed: " + e.getMessage(), android.widget.Toast.LENGTH_SHORT).show();
        }
    }

    private void showDroidShellTools() {
        try {
            String cmd =
                "echo '=== DroidShell Tools ==='; " +
                "echo 'Home: $HOME'; " +
                "echo 'Prefix: $PREFIX'; " +
                "echo 'Startup: $HOME/.droidshell-startup'; " +
                "bash";
            TermuxSessionActivity.startShellSession(this, cmd, null);
        } catch (Exception e) {
            android.widget.Toast.makeText(this, "DroidShell tools failed: " + e.getMessage(), android.widget.Toast.LENGTH_SHORT).show();
        }
    }
EOCODE
fi

# -----------------------------------------
# INITIAL COMMIT
# -----------------------------------------
if git log --pretty=oneline | grep -q "Initial DroidShell commit"; then
    echo "[DroidShell] Initial commit already exists — skipping."
else
    git add .
    git commit -m "Initial DroidShell commit: merged Java menu injector"
fi

echo "[DroidShell] Project ready."
