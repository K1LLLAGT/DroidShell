#!/usr/bin/env bash
# DroidShell :: root/modules/selinux_inspect.sh
# Read and inspect SELinux policy; build/load custom policy modules (audit only).
# Usage: selinux_inspect.sh status|audit|dump|allow-module <args>

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }

case "${1:-status}" in
  status)
    echo -e "${C}SELinux status:${N}"
    su -c "getenforce 2>/dev/null || cat /sys/fs/selinux/enforce 2>/dev/null || echo N/A"
    echo -e "${C}Policy version:${N}"
    su -c "cat /sys/fs/selinux/policyvers 2>/dev/null || echo N/A"
    echo -e "${C}Contexts:${N}"
    su -c "ls /sys/fs/selinux/" 2>/dev/null
    ;;

  audit)
    echo -e "${C}SELinux AVC denials (last 500):${N}"
    su -c "logcat -b all -d 2>/dev/null | grep 'avc:' | tail -500"
    ;;

  dump)
    out="${2:-${HOME}/DroidShell/logs/policy.bin}"
    su -c "cat /sys/fs/selinux/policy" > "$out"
    echo -e "${G}[✓] Policy binary → ${out}${N}"
    echo "Decompile with: sesearch/seinfo from policycoreutils"
    ;;

  allow-module)
    # Build a targeted allow-rule module from AVC denials (audit2allow pattern)
    [[ -n "${2:-}" ]] || { echo "Usage: selinux_inspect.sh allow-module <out.te>"; exit 1; }
    out_te="$2"
    echo -e "${Y}Generating allow rules from recent AVC denials...${N}"
    su -c "logcat -b all -d 2>/dev/null | grep 'avc: denied'" \
      | sed "s/.*avc:  denied  { /allow /; s/ } for .*/;/" \
      | sort -u > "$out_te"
    echo -e "${G}[✓] Candidate rules → ${out_te}${N}"
    echo -e "${Y}Review carefully before loading with: semodule -i${N}"
    ;;

  *)
    echo "Usage: selinux_inspect.sh status|audit|dump|allow-module [args]"
    ;;
esac
