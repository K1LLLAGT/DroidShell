#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="$HOME/.droidshell/etc"

echo "[DroidShell] Creating /etc-style config tree at $BASE"

mkdir -p "$BASE/colors" \
         "$BASE/keys" \
         "$BASE/profile" \
         "$BASE/plugins" \
         "$BASE/system" \
         "$BASE/logs"

# Colors
cat > "$BASE/colors/droidshell-dark.conf" << 'EOCOL'
background=#0D0D0D
foreground=#E0E0E0
cursor=#00FF66
EOCOL

# Keys
cat > "$BASE/keys/extra-keys.conf" << 'EOKEY'
[['ESC','CTRL','ALT','TAB','HOME','END'],
 ['UP','DOWN','LEFT','RIGHT','DEL','BKSP']]
EOKEY

# Shell profile
cat > "$BASE/profile/droidshell-profile.sh" << 'EOPROF'
export PATH="$HOME/bin:$PATH"
alias ll='ls -alF'
alias gs='git status'
EOPROF

# System defaults
cat > "$BASE/system/defaults.conf" << 'EOSYS'
theme=droidshell-dark
extra_keys=enabled
startup_script=~/.droidshell-startup
EOSYS

# MOTD
cat > "$BASE/system/motd" << 'EOMOTD'
Welcome to DroidShell — Android Terminal Emulator
EOMOTD

echo "[DroidShell] /etc tree created."
