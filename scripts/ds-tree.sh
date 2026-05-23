#!/data/data/com.termux/files/usr/bin/bash
mkdir -p source/DroidShell/app source/DroidShell/.gradle workspace/logs workspace/tmp
cat << 'EOF2' > .gitignore
source/DroidShell/app/build/
source/DroidShell/.gradle/
workspace/tmp/
workspace/logs/
.DS_Store
Thumbs.db
EOF2
