#!/usr/bin/env bash
# ds-root-extra-modules.sh
# Adds 10 extra rooted modules and merges them into the existing root suite.

set -euo pipefail

BANNER="
  ____            _     _ ____  _          _ _
 |  _ \ _ __ ___ (_) __| / ___|| |__   ___| | |
 | | | | '__/ _ \| |/ _\` \___ \| '_ \ / _ \ | |
 | |_| | | | (_) | | (_| |___) | | | |  __/ | |
 |____/|_|  \___/|_|\__,_|____/|_| |_|\___|_|_|
  Root Extra Modules  ·  technician-grade
"

echo "$BANNER"
echo
echo "Targets:"
echo "  • /sdcard/Documents/DroidShell"
echo "  • $HOME/DroidShell"
echo

TARGETS=(
  "/sdcard/Documents/DroidShell"
  "$HOME/DroidShell"
)

for BASE in "${TARGETS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " Generating into: $BASE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  ROOT_DIR="$BASE/root"
  MOD_DIR="$ROOT_DIR/modules"

  mkdir -p "$MOD_DIR"

  ############################################
  # 1) sysprops.sh
  ############################################
  cat << 'SH1' > "$MOD_DIR/sysprops.sh"
#!/usr/bin/env bash
set -euo pipefail
CMD="${1:-list}"
case "$CMD" in
  list) su -c "getprop" ;;
  get) su -c "getprop \"$2\"" ;;
  set) su -c "resetprop \"$2\" \"$3\"" ;;
  *) echo "Usage: $0 [list|get|set]" ;;
esac
SH1
  chmod +x "$MOD_DIR/sysprops.sh"
  echo "[GEN] sysprops.sh"

  ############################################
  # 2) services.sh
  ############################################
  cat << 'SH2' > "$MOD_DIR/services.sh"
#!/usr/bin/env bash
set -euo pipefail
CMD="${1:-list}"
case "$CMD" in
  list) su -c "service list" ;;
  raw) shift; su -c "service $*" ;;
  *) echo "Usage: $0 [list|raw]" ;;
esac
SH2
  chmod +x "$MOD_DIR/services.sh"
  echo "[GEN] services.sh"

  ############################################
  # 3) thermal.sh
  ############################################
  cat << 'SH3' > "$MOD_DIR/thermal.sh"
#!/usr/bin/env bash
set -euo pipefail
echo "== thermal =="
su -c "ls -R /sys/class/thermal"
echo
echo "== power_supply =="
su -c "ls -R /sys/class/power_supply"
SH3
  chmod +x "$MOD_DIR/thermal.sh"
  echo "[GEN] thermal.sh"

  ############################################
  # 4) kernel.sh
  ############################################
  cat << 'SH4' > "$MOD_DIR/kernel.sh"
#!/usr/bin/env bash
set -euo pipefail
echo "== /proc/sys =="
su -c "ls -R /proc/sys"
echo
echo "== /sys/module =="
su -c "ls -R /sys/module"
SH4
  chmod +x "$MOD_DIR/kernel.sh"
  echo "[GEN] kernel.sh"

  ############################################
  # 5) mounts.sh
  ############################################
  cat << 'SH5' > "$MOD_DIR/mounts.sh"
#!/usr/bin/env bash
set -euo pipefail
su -c "mount"
SH5
  chmod +x "$MOD_DIR/mounts.sh"
  echo "[GEN] mounts.sh"

  ############################################
  # 6) storage.sh
  ############################################
  cat << 'SH6' > "$MOD_DIR/storage.sh"
#!/usr/bin/env bash
set -euo pipefail
echo "== /dev/block =="
su -c "ls -R /dev/block"
echo
echo "== /proc/partitions =="
su -c "cat /proc/partitions"
SH6
  chmod +x "$MOD_DIR/storage.sh"
  echo "[GEN] storage.sh"

  ############################################
  # 7) scheduler.sh
  ############################################
  cat << 'SH7' > "$MOD_DIR/scheduler.sh"
#!/usr/bin/env bash
set -euo pipefail
echo "== /proc/sched_debug =="
su -c "cat /proc/sched_debug"
echo
echo "== CPU sysfs =="
su -c "ls -R /sys/devices/system/cpu"
SH7
  chmod +x "$MOD_DIR/scheduler.sh"
  echo "[GEN] scheduler.sh"

  ############################################
  # 8) memory.sh
  ############################################
  cat << 'SH8' > "$MOD_DIR/memory.sh"
#!/usr/bin/env bash
set -euo pipefail
echo "== /proc/meminfo =="
su -c "cat /proc/meminfo"
echo
echo "== /proc/slabinfo =="
su -c "cat /proc/slabinfo"
SH8
  chmod +x "$MOD_DIR/memory.sh"
  echo "[GEN] memory.sh"

  ############################################
  # 9) firewall.sh
  ############################################
  cat << 'SH9' > "$MOD_DIR/firewall.sh"
#!/usr/bin/env bash
set -euo pipefail
echo "== iptables =="
su -c "iptables -L -n -v"
echo
echo "== ip6tables =="
su -c "ip6tables -L -n -v"
SH9
  chmod +x "$MOD_DIR/firewall.sh"
  echo "[GEN] firewall.sh"

  ############################################
  # 10) dns.sh
  ############################################
  cat << 'SH10' > "$MOD_DIR/dns.sh"
#!/usr/bin/env bash
set -euo pipefail
echo "== resolv.conf =="
su -c "cat /etc/resolv.conf"
echo
echo "== net.dns props =="
su -c "getprop | grep -i net.dns"
SH10
  chmod +x "$MOD_DIR/dns.sh"
  echo "[GEN] dns.sh"

  ############################################
  # Merge into ds_root.sh
  ############################################
  DS_ROOT="$BASE/ds_root.sh"
  if [ -f "$DS_ROOT" ]; then
    if ! grep -q "EXTRA_ROOT_MODULES" "$DS_ROOT"; then
      cat << 'APPEND' >> "$DS_ROOT"

# EXTRA_ROOT_MODULES
root_extra_menu() {
  cat << EOM
[Extra Root Modules]
  sp    - system properties
  svc   - service manager
  th    - thermal/power
  krn   - kernel params
  mnt   - mounts
  stor  - storage map
  sch   - scheduler
  mem   - memory
  fw    - firewall
  dns   - DNS
EOM
}
APPEND
      echo "[MERGE] updated ds_root.sh"
    else
      echo "[SKIP] ds_root.sh already patched"
    fi
  else
    echo "[WARN] ds_root.sh not found at $DS_ROOT"
  fi

  echo "✓ Completed for $BASE"
done

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Root Extra Modules — Generation Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
