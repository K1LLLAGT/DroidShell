#!/data/data/com.termux/files/usr/bin/bash
# ds-all-in-one.sh — generates full DroidShell script suite (19 scripts)

###############################################
# Existing 15 scripts (unchanged)
###############################################

# (1) ds-bootstrap.sh
echo "[+] Generating ds-bootstrap.sh..."
cat << 'EOT' > ds-bootstrap.sh
#!/data/data/com.termux/files/usr/bin/bash
mkdir -p scripts source/DroidShell docs tools etc workspace
cat << 'EOF2' > scripts/ds-init.sh
#!/data/data/com.termux/files/usr/bin/bash
mkdir -p workspace/build workspace/cache
EOF2
cat << 'EOF2' > docs/README.md
# DroidShell Documentation
EOF2
cat << 'EOF2' > etc/config.yml
version: 1
EOF2
cat << 'EOF2' > tools/README.md
# DroidShell Tools
EOF2
EOT

# (2) signing-policy.sh
echo "[+] Generating signing-policy.sh..."
cat << 'EOT' > signing-policy.sh
#!/data/data/com.termux/files/usr/bin/bash
mkdir -p ~/.ssh
echo "g19479574996t@gmail.com $(cat ~/.ssh/id_ed25519.pub)" > ~/.ssh/allowed_signers
git config --global user.name "Greg"
git config --global user.email "g19479574996t@gmail.com"
git config --global url."git@github.com:".insteadOf "https://github.com/"
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
git config --global tag.gpgsign true
git config --global gpg.program gpg
git config --global push.autoSetupRemote true
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global fetch.prune true
git config --global core.autocrlf input
EOT

# (3) ds-tree.sh
echo "[+] Generating ds-tree.sh..."
cat << 'EOT' > ds-tree.sh
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
EOT

# (4) ds-plugin-sdk.sh
echo "[+] Generating ds-plugin-sdk.sh..."
cat << 'EOT' > ds-plugin-sdk.sh
#!/data/data/com.termux/files/usr/bin/bash
mkdir -p plugins/templates plugins/sdk
cat << 'EOF2' > plugins/templates/plugin-template.sh
#!/data/data/com.termux/files/usr/bin/bash
echo "Plugin template"
EOF2
EOT

# (5) ds-build-suite.sh
echo "[+] Generating ds-build-suite.sh..."
cat << 'EOT' > ds-build-suite.sh
#!/data/data/com.termux/files/usr/bin/bash
mkdir -p build build/logs
cat << 'EOF2' > build/build-all.sh
#!/data/data/com.termux/files/usr/bin/bash
echo "[BUILD] Full build"
EOF2
EOT

# (6) ds-env-installer.sh
echo "[+] Generating ds-env-installer.sh..."
cat << 'EOT' > ds-env-installer.sh
#!/data/data/com.termux/files/usr/bin/bash
./ds-bootstrap.sh
./ds-tree.sh
./ds-plugin-sdk.sh
./ds-build-suite.sh
./signing-policy.sh
EOT

# (7) ds-plugin-loader.sh
echo "[+] Generating ds-plugin-loader.sh..."
cat << 'EOT' > ds-plugin-loader.sh
#!/data/data/com.termux/files/usr/bin/bash
for p in plugins/*.sh; do [ -e "$p" ] && bash "$p"; done
EOT

# (8) ds-pkg.sh
echo "[+] Generating ds-pkg.sh..."
cat << 'EOT' > ds-pkg.sh
#!/data/data/com.termux/files/usr/bin/bash
echo "[PKG] Stub"
EOT

# (9) ds-logging.sh
echo "[+] Generating ds-logging.sh..."
cat << 'EOT' > ds-logging.sh
#!/data/data/com.termux/files/usr/bin/bash
log(){ echo "[LOG] $*"; }
EOT

# (10) ds-build-pipeline.sh
echo "[+] Generating ds-build-pipeline.sh..."
cat << 'EOT' > ds-build-pipeline.sh
#!/data/data/com.termux/files/usr/bin/bash
bash build/build-all.sh
EOT

# (11) ds-release-pack.sh
echo "[+] Generating ds-release-pack.sh..."
cat << 'EOT' > ds-release-pack.sh
#!/data/data/com.termux/files/usr/bin/bash
echo "[RELEASE] Stub"
EOT

# (12) ds-test-runner.sh
echo "[+] Generating ds-test-runner.sh..."
cat << 'EOT' > ds-test-runner.sh
#!/data/data/com.termux/files/usr/bin/bash
echo "[TEST] Stub"
EOT

# (13) ds-cli.sh
echo "[+] Generating ds-cli.sh..."
cat << 'EOT' > ds-cli.sh
#!/data/data/com.termux/files/usr/bin/bash
case "$1" in init) ./ds-bootstrap.sh;; build) ./ds-build-pipeline.sh;; esac
EOT

# (14) ds-workspace.sh
echo "[+] Generating ds-workspace.sh..."
cat << 'EOT' > ds-workspace.sh
#!/data/data/com.termux/files/usr/bin/bash
echo "[WS] Stub"
EOT

# (15) ds-doctor.sh
echo "[+] Generating ds-doctor.sh..."
cat << 'EOT' > ds-doctor.sh
#!/data/data/com.termux/files/usr/bin/bash
echo "[DOCTOR] Stub"
EOT


###############################################
# NEW 4 SYSTEMS (Set D)
###############################################

# (16) ds-pkg-repo-server.sh
echo "[+] Generating ds-pkg-repo-server.sh..."
cat << 'EOT' > ds-pkg-repo-server.sh
#!/data/data/com.termux/files/usr/bin/bash
mkdir -p repo
echo "[PKG-REPO] Local package repo ready."
EOT

# (17) ds-plugin-metadata.sh
echo "[+] Generating ds-plugin-metadata.sh..."
cat << 'EOT' > ds-plugin-metadata.sh
#!/data/data/com.termux/files/usr/bin/bash
mkdir -p plugins/meta
echo "{ \"plugins\": [] }" > plugins/meta/index.json
EOT

# (18) ds-gradle-build.sh
echo "[+] Generating ds-gradle-build.sh..."
cat << 'EOT' > ds-gradle-build.sh
#!/data/data/com.termux/files/usr/bin/bash
echo "[GRADLE] Running Gradle build (stub)"
EOT

# (19) ds-tui.sh
echo "[+] Generating ds-tui.sh..."
cat << 'EOT' > ds-tui.sh
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
EOT


###############################################
# Finalize
###############################################
echo "[+] Setting executable permissions..."
chmod +x *.sh
echo "[✓] All 19 scripts generated successfully."
