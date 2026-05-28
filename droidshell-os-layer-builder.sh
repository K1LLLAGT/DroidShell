#!/usr/bin/env bash
set -euo pipefail

# droidshell-os-layer-builder.sh
# Build the full DroidShell OS layer tree with example content.

# Target roots (external + internal-style)
PUBLIC_ROOT="${1:-/sdcard/DroidShell}"
INTERNAL_ROOT="${2:-./DroidShell_internal}"

echo "=== DroidShell OS Layer Builder ==="
echo "Public root:   $PUBLIC_ROOT"
echo "Internal root: $INTERNAL_ROOT"
echo

mkdir -p "$PUBLIC_ROOT" "$INTERNAL_ROOT"

make_tree() {
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

  # --- bin ---
  cat > "$ROOT/bin/droidshell-env.sh" <<'EOF'
#!/usr/bin/env sh
# DroidShell environment info
echo "DroidShell environment:"
echo "  PWD: $(pwd)"
echo "  USER: $(whoami 2>/dev/null || echo unknown)"
EOF
  chmod +x "$ROOT/bin/droidshell-env.sh"

  cat > "$ROOT/bin/droidshell-version.sh" <<'EOF'
#!/usr/bin/env sh
# DroidShell version stub
echo "DroidShell OS Layer"
echo "Version: 0.1.0-dev"
EOF
  chmod +x "$ROOT/bin/droidshell-version.sh"

  cat > "$ROOT/bin/droidshell-diagnostics.sh" <<'EOF'
#!/usr/bin/env sh
# Basic diagnostics for DroidShell
echo "=== DroidShell Diagnostics ==="
echo "Date: $(date 2>/dev/null || echo unknown)"
echo "Uname: $(uname -a 2>/dev/null || echo unknown)"
echo "Shell: $SHELL"
echo "PATH: $PATH"
EOF
  chmod +x "$ROOT/bin/droidshell-diagnostics.sh"

  # --- plugins/example ---
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
# Example DroidShell plugin
echo "[Example Plugin] Hello from DroidShell plugin!"
echo "[Example Plugin] Working directory: $(pwd)"
EOF
  chmod +x "$ROOT/plugins/example/plugin.sh"

  # --- themes ---
  cat > "$ROOT/themes/default.json" <<'EOF'
{
  "name": "Default",
  "accent": "#00FF7F",
  "background": "#101010",
  "title": "#FFFFFF",
  "tint": "#00FF7F"
}
EOF

  # --- scripts ---
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

  # --- workspace ---
  cat > "$ROOT/workspace/README.txt" <<'EOF'
DroidShell workspace
--------------------
This directory is intended for user data, temporary files, and
workspace-specific artifacts created by DroidShell or its plugins.
EOF

  # --- packages ---
  cat > "$ROOT/packages/README.txt" <<'EOF'
DroidShell packages
-------------------
Reserved for future package/module distribution and installation.
EOF

  # --- config ---
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

  # --- logs ---
  touch "$ROOT/logs/.gitkeep"

  echo "   Done: $ROOT"
  echo
}

make_tree "$PUBLIC_ROOT"
make_tree "$INTERNAL_ROOT"

echo "=== DroidShell OS layer provisioned ==="
echo "You can now install and run DroidShell.apk against these roots."
