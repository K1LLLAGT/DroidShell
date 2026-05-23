#!/data/data/com.termux/files/usr/bin/bash
for p in plugins/*.sh; do [ -e "$p" ] && bash "$p"; done
