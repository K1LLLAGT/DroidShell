#!/usr/bin/env bash
set -euo pipefail

# build_droidshell_os.sh
# Full unified builder for the DroidShell OS layer + APK resource stubs.

PUBLIC_ROOT="${1:-/sdcard/DroidShell}"
INTERNAL_ROOT="${2:-./DroidShell_internal}"
APK_RES_ROOT="${3:-./APK_Resources}"

echo "=== DroidShell OS Layer Builder ==="
echo "Public root:   $PUBLIC_ROOT"
echo "Internal root: $INTERNAL_ROOT"
echo "APK res root:  $APK_RES_ROOT"
echo

mkdir -p "$PUBLIC_ROOT" "$INTERNAL_ROOT" "$APK_RES_ROOT/drawable" "$APK_RES_ROOT/raw"

###############################################
# FUNCTION: BUILD OS ROOT
###############################################
build_root() {
  local ROOT="$1"
  echo "-> Provisioning: $ROOT"

  mkdir -p \
    "$ROOT/bin" \
    "$ROOT/plugins" \
    "$ROOT/themes" \
    "$ROOT/scripts" \
    "$ROOT/workspace" \
    "$ROOT/packages" \
    "$ROOT/config" \
    "$ROOT/logs"

  ########################################
  # BIN SCRIPTS
  ########################################
  cat > "$ROOT/bin/droidshell-env.sh" <<'EOF'
#!/usr/bin/env sh
echo "DroidShell Environment:"
echo "PWD: $(pwd)"
echo "USER: $(whoami 2>/dev/null || echo unknown)"
EOF
  chmod +x "$ROOT/bin/droidshell-env.sh"

  cat > "$ROOT/bin/droidshell-version.sh" <<'EOF'
#!/usr/bin/env sh
echo "DroidShell OS Layer"
echo "Version: 0.1.0-dev"
EOF
  chmod +x "$ROOT/bin/droidshell-version.sh"

  cat > "$ROOT/bin/droidshell-diagnostics.sh" <<'EOF'
#!/usr/bin/env sh
echo "=== DroidShell Diagnostics ==="
echo "Date: $(date 2>/dev/null || echo unknown)"
echo "Uname: $(uname -a 2>/dev/null || echo unknown)"
echo "Shell: $SHELL"
echo "PATH: $PATH"
EOF
  chmod +x "$ROOT/bin/droidshell-diagnostics.sh"

  ########################################
  # PLUGINS
  ########################################
  mkdir -p "$ROOT/plugins/example"

  cat > "$ROOT/plugins/example/manifest.json" <<'EOF'
{
  "id": "example",
  "name": "Example Plugin",
  "version": "0.1.0",
  "description": "Sample DroidShell plugin for validation and testing.",
  "entry": "plugin.sh"
}
EOF

  cat > "$ROOT/plugins/example/plugin.sh" <<'EOF'
#!/usr/bin/env sh
echo "[Example Plugin] Hello from DroidShell plugin!"
echo "[Example Plugin] Working directory: $(pwd)"
EOF
  chmod +x "$ROOT/plugins/example/plugin.sh"

  ########################################
  # THEMES
  ########################################
  cat > "$ROOT/themes/default.json" <<'EOF'
{
  "name": "Default",
  "accent": "#00FF7F",
  "background": "#101010",
  "title": "#FFFFFF",
  "tint": "#00FF7F"
}
EOF

  ########################################
  # SCRIPTS
  ########################################
  cat > "$ROOT/scripts/test.sh" <<'EOF'
#!/usr/bin/env sh
echo "[DroidShell Test Script]"
echo "PWD: $(pwd)"
echo "ARGS: $@"
EOF
  chmod +x "$ROOT/scripts/test.sh"

  cat > "$ROOT/scripts/hello.sh" <<'EOF'
#!/usr/bin/env sh
echo "Hello from DroidShell scripts!"
EOF
  chmod +x "$ROOT/scripts/hello.sh"

  ########################################
  # WORKSPACE
  ########################################
  cat > "$ROOT/workspace/README.txt" <<'EOF'
DroidShell workspace
--------------------
This directory is intended for user data, temporary files, and
workspace-specific artifacts created by DroidShell or its plugins.
EOF

  ########################################
  # PACKAGES
  ########################################
  cat > "$ROOT/packages/README.txt" <<'EOF'
DroidShell packages
-------------------
Reserved for future package/module distribution and installation.
EOF

  ########################################
  # CONFIG
  ########################################
  cat > "$ROOT/config/droidshell.json" <<'EOF'
{
  "version": "0.1.0",
  "defaultTheme": "default",
  "defaultShell": "/system/bin/sh",
  "allowExternalScripts": true,
  "plugin": {
    "enabled": true,
    "scanInternal": true,
    "scanPublic": true
  },
  "logging": {
    "enabled": true,
    "level": "INFO"
  }
}
EOF

  cat > "$ROOT/config/droidshell_theme.json" <<'EOF'
{
  "accent": "#00FF7F",
  "background": "#101010",
  "title": "#FFFFFF",
  "tint": "#00FF7F"
}
EOF

  cat > "$ROOT/config/droidshell_icon_map.json" <<'EOF'
{
  "bin": "ic_droidshell_bin",
  "plugins": "ic_droidshell_plugins",
  "themes": "ic_droidshell_themes",
  "scripts": "ic_droidshell_scripts",
  "workspace": "ic_droidshell_workspace",
  "packages": "ic_droidshell_packages",
  "config": "ic_droidshell_config",
  "logs": "ic_droidshell_logs"
}
EOF

  ########################################
  # LOGS
  ########################################
  touch "$ROOT/logs/.gitkeep"

  echo "   Done: $ROOT"
  echo
}

###############################################
# BUILD BOTH ROOTS
###############################################
build_root "$PUBLIC_ROOT"
build_root "$INTERNAL_ROOT"

###############################################
# APK RESOURCE STUBS
###############################################
echo "=== Generating APK resource stubs ==="

# RAW resources
cp "$PUBLIC_ROOT/config/droidshell_theme.json" "$APK_RES_ROOT/raw/droidshell_theme.json"
cp "$PUBLIC_ROOT/config/droidshell_icon_map.json" "$APK_RES_ROOT/raw/droidshell_icon_map.json"

# Drawable placeholders
for icon in \
  ic_droidshell_bin \
  ic_droidshell_plugins \
  ic_droidshell_themes \
  ic_droidshell_scripts \
  ic_droidshell_workspace \
  ic_droidshell_packages \
  ic_droidshell_config \
  ic_droidshell_logs \
  ic_folder_default
do
  cat > "$APK_RES_ROOT/drawable/${icon}.xml" <<EOF
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#00FF7F"
        android:pathData="M4,4h16v16h-16z"/>
</vector>
EOF
done

echo
echo "=== DroidShell OS layer + APK resource stubs generated ==="
echo "Copy APK_Resources/drawable/* into app/src/main/res/drawable/"
echo "Copy APK_Resources/raw/* into app/src/main/res/raw/"
echo
echo "Your DroidShell.apk will now run correctly against this OS layer."
