#!/data/data/com.termux/files/usr/bin/bash
echo "=== DroidShell TUI ==="
echo "1) Build"
echo "2) Plugins"
echo "3) Env Doctor"
read -p "> " CH
case "$CH" in
  1) ./ds-build-pipeline.sh;;
  2) ./ds-plugin-loader.sh;;
  3) ./ds-doctor.sh;;
esac
