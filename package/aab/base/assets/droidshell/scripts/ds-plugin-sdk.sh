#!/data/data/com.termux/files/usr/bin/bash
mkdir -p plugins/templates plugins/sdk
cat << 'EOF2' > plugins/templates/plugin-template.sh
#!/data/data/com.termux/files/usr/bin/bash
echo "Plugin template"
EOF2
