#!/data/data/com.termux/files/usr/bin/bash
# ds-bundle-installer.sh — CAT bundle installer for all DroidShell scripts

echo "[+] Creating ds-bootstrap.sh..."
cat << 'EOT' > ds-bootstrap.sh
#!/data/data/com.termux/files/usr/bin/bash
# ds-bootstrap.sh — DroidShell canonical tree generator

mkdir -p scripts
mkdir -p source/DroidShell
mkdir -p docs
mkdir -p tools
mkdir -p etc
mkdir -p workspace

cat << 'EOF2' > scripts/ds-init.sh
#!/data/data/com.termux/files/usr/bin/bash
echo "Initializing DroidShell workspace..."
mkdir -p workspace/build
mkdir -p workspace/cache
EOF2

cat << 'EOF2' > docs/README.md
# DroidShell Documentation
This directory contains all project documentation.
EOF2

cat << 'EOF2' > etc/config.yml
# DroidShell global configuration
version: 1
EOF2

cat << 'EOF2' > tools/README.md
# DroidShell Tools
Utility scripts and helpers.
EOF2

echo "DroidShell canonical tree created."
EOT


echo "[+] Creating signing-policy.sh..."
cat << 'EOT' > signing-policy.sh
#!/data/data/com.termux/files/usr/bin/bash
# signing-policy.sh — universal signing policy installer

mkdir -p ~/.ssh

# Insert your actual SSH public key automatically
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

echo "Universal signing policy applied."
EOT


echo "[+] Creating ds-tree.sh..."
cat << 'EOT' > ds-tree.sh
#!/data/data/com.termux/files/usr/bin/bash
# ds-tree.sh — DroidShell canonical folder tree hardening

mkdir -p source/DroidShell/app
mkdir -p source/DroidShell/.gradle
mkdir -p workspace/logs
mkdir -p workspace/tmp

cat << 'EOF2' > .gitignore
# Android build artifacts
source/DroidShell/app/build/
source/DroidShell/.gradle/

# Workspace
workspace/tmp/
workspace/logs/

# OS junk
.DS_Store
Thumbs.db
EOF2

echo "Canonical folder tree hardened."
EOT


echo "[+] Setting executable permissions..."
chmod +x ds-bootstrap.sh
chmod +x signing-policy.sh
chmod +x ds-tree.sh

echo "[✓] All scripts generated successfully."
