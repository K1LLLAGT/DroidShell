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
