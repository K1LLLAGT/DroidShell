#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/DroidShell"

if [ -d "$TARGET/.git" ]; then
  echo "DroidShell already present at $TARGET"
  exit 0
fi

git clone https://github.com/K1LLLAGT/DroidShell.git "$TARGET"

cd "$TARGET"
mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/ds" << 'EOF_DSLAUNCH'
#!/usr/bin/env bash
exec "$HOME/DroidShell/scripts/ds-cli.sh" "$@"
EOF_DSLAUNCH
chmod +x "$HOME/.local/bin/ds"

echo "Add to PATH if needed:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
