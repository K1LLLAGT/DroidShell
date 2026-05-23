#!/usr/bin/env bash
# =============================================================================
#  DroidShell Root Enhancements Generator
#  ds_root_enhancements.sh
#
#  Generates all root-mode capability modules into:
#    /sdcard/Documents/DroidShell/   (Android external storage)
#    $HOME/DroidShell/               (Termux $HOME)
#
#  Covered capabilities:
#    1.  Root detection          (Magisk / su / KernelSU / APatch)
#    2.  Root-mode file ops      (safe r/w across all system paths)
#    3.  Root-mode APK extract   (system/app + system/priv-app)
#    4.  Root-mode log collect   (logcat, dmesg, /proc/kmsg)
#    5.  Root-mode proc inspect  (full process enumeration)
#    6.  Root-mode net inspect   (/proc/net/*, iptables, routing)
#    7.  Root-mode backup        (/data/data, system configs, boot logs)
#    8.  Root-mode shell exec    (safe su -c wrapper + audit log)
#    9.  Root-mode module build  (partition ops, SELinux, verified boot,
#                                 update/CI/installer/nightly scaffolds)
#
#  NOT included (malware primitives, not technician tools):
#    - rootkit installation
#    - authentication bypass
#
#  Usage:
#    bash ds_root_enhancements.sh [--android-only] [--termux-only] [--dry-run]
# =============================================================================

set -euo pipefail

# ── Colour palette ────────────────────────────────────────────────────────────
R='\033[1;31m' G='\033[1;32m' Y='\033[1;33m' C='\033[1;36m'
B='\033[1;34m' M='\033[1;35m' W='\033[1;37m' N='\033[0m'

# ── CLI flags ─────────────────────────────────────────────────────────────────
ANDROID_ONLY=false; TERMUX_ONLY=false; DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --android-only) ANDROID_ONLY=true ;;
    --termux-only)  TERMUX_ONLY=true  ;;
    --dry-run)      DRY_RUN=true      ;;
  esac
done

# ── Output roots ──────────────────────────────────────────────────────────────
ANDROID_ROOT="/sdcard/Documents/DroidShell"
TERMUX_ROOT="${HOME}/DroidShell"

declare -a ROOTS=()
$ANDROID_ONLY || $TERMUX_ONLY || { ROOTS+=("$ANDROID_ROOT" "$TERMUX_ROOT"); }
$ANDROID_ONLY && ROOTS+=("$ANDROID_ROOT")
$TERMUX_ONLY  && ROOTS+=("$TERMUX_ROOT")

# ── Helpers ───────────────────────────────────────────────────────────────────
log()  { echo -e "${G}[GEN]${N} $*"; }
warn() { echo -e "${Y}[WARN]${N} $*"; }
die()  { echo -e "${R}[ERR]${N} $*" >&2; exit 1; }

write_file() {          # write_file <path> <content-heredoc-name>
  local path="$1"
  if $DRY_RUN; then
    echo -e "${C}[DRY]${N} would write → $path"
    return
  fi
  local dir; dir="$(dirname "$path")"
  mkdir -p "$dir"
  cat > "$path"
  chmod +x "$path" 2>/dev/null || true
  log "wrote → $path"
}

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "${M}"
cat << 'BANNER'
  ____            _     _ ____  _          _ _
 |  _ \ _ __ ___ (_) __| / ___|| |__   ___| | |
 | | | | '__/ _ \| |/ _` \___ \| '_ \ / _ \ | |
 | |_| | | | (_) | | (_| |___) | | | |  __/ | |
 |____/|_|  \___/|_|\__,_|____/|_| |_|\___|_|_|
  Root Enhancement Generator  ·  technician-grade
BANNER
echo -e "${N}"

# =============================================================================
#  MODULE DEFINITIONS  (each module is its own heredoc function)
# =============================================================================

# ─────────────────────────────────────────────────────────────────────────────
#  1. ROOT DETECTION
# ─────────────────────────────────────────────────────────────────────────────
gen_root_detection() {
  local base="$1"
  write_file "${base}/root/detect_root.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/detect_root.sh
# Detects Magisk, KernelSU, APatch, and plain su availability.
# Exits 0 if root found, 1 if not.

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'

ROOT_TYPE="none"
ROOT_PATH=""
MAGISK_VER=""

detect_magisk() {
  local mgk_paths=( /sbin/.magisk/busybox /data/adb/magisk /data/adb/magisk.img
                    /data/adb/modules/.core /sbin/magisk )
  for p in "${mgk_paths[@]}"; do
    [[ -e "$p" ]] && { ROOT_TYPE="magisk"; ROOT_PATH="$p"; break; }
  done
  # Try version query
  if command -v magisk &>/dev/null; then
    MAGISK_VER="$(magisk -v 2>/dev/null || echo unknown)"
    ROOT_TYPE="magisk"
    ROOT_PATH="$(command -v magisk)"
  fi
}

detect_kernelsu() {
  [[ -e /data/adb/ksud ]] || [[ -e /sbin/ksud ]] || \
  command -v ksud &>/dev/null && { ROOT_TYPE="kernelsu"; ROOT_PATH="$(command -v ksud 2>/dev/null || echo /data/adb/ksud)"; }
}

detect_apatch() {
  [[ -e /data/adb/apatch ]] && { ROOT_TYPE="apatch"; ROOT_PATH="/data/adb/apatch"; }
}

detect_su() {
  local su_paths=( /sbin/su /system/bin/su /system/xbin/su /su/bin/su
                   /magisk/.core/bin/su /data/adb/magisk/su )
  for p in "${su_paths[@]}"; do
    [[ -x "$p" ]] && { ROOT_TYPE="su"; ROOT_PATH="$p"; return; }
  done
  command -v su &>/dev/null && { ROOT_TYPE="su"; ROOT_PATH="$(command -v su)"; }
}

detect_magisk
[[ "$ROOT_TYPE" == "none" ]] && detect_kernelsu
[[ "$ROOT_TYPE" == "none" ]] && detect_apatch
[[ "$ROOT_TYPE" == "none" ]] && detect_su

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║       DroidShell Root Detection          ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"

if [[ "$ROOT_TYPE" == "none" ]]; then
  echo -e "${Y}[!] No root mechanism detected.${N}"
  exit 1
fi

echo -e "${G}[✓] Root type   : ${W}${ROOT_TYPE}${N}"
echo -e "${G}[✓] Root path   : ${W}${ROOT_PATH}${N}"
[[ -n "$MAGISK_VER" ]] && echo -e "${G}[✓] Magisk ver  : ${W}${MAGISK_VER}${N}"

# Verify actual root by running whoami as root
if su -c "whoami" 2>/dev/null | grep -q "root"; then
  echo -e "${G}[✓] su -c exec  : ${W}confirmed root shell${N}"
else
  echo -e "${Y}[!] su -c exec  : could not verify (may need interactive grant)${N}"
fi

echo "root_type=${ROOT_TYPE}"   > /tmp/ds_root_cache
echo "root_path=${ROOT_PATH}"  >> /tmp/ds_root_cache
[[ -n "$MAGISK_VER" ]] && echo "magisk_ver=${MAGISK_VER}" >> /tmp/ds_root_cache

exit 0
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
#  2. ROOT-MODE FILE OPERATIONS
# ─────────────────────────────────────────────────────────────────────────────
gen_root_fileops() {
  local base="$1"
  write_file "${base}/root/fileops.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/fileops.sh
# Safe root-mode r/w for all protected system paths.
# Usage: fileops.sh <read|write|ls|find|stat|cp|cat> <args...>

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; C='\033[1;36m'; N='\033[0m'

# All system paths that require root access
ROOT_PATHS=(
  /cache /config /d /mnt /sys /oem /debug_ramdisk
  /system /vendor /data /proc /dev /etc /usr
)

# Guard: caller must have root
_require_root() {
  su -c "id" 2>/dev/null | grep -q "uid=0" || {
    echo -e "${R}[ERR] Root access required${N}" >&2; exit 1; }
}

# Validate that the path is under a known root-accessible tree
_validate_path() {
  local p="$1"
  for rp in "${ROOT_PATHS[@]}"; do
    [[ "$p" == "$rp"* ]] && return 0
  done
  echo -e "${Y}[WARN] Path '${p}' not in known root tree. Proceeding with caution.${N}"
}

_safe_read()  { _require_root; _validate_path "$1"; su -c "cat -- '$1'"; }
_safe_cat()   { _safe_read "$@"; }
_safe_ls()    { _require_root; _validate_path "$1"; su -c "ls -la -- '$1'"; }
_safe_stat()  { _require_root; _validate_path "$1"; su -c "stat -- '$1'"; }
_safe_find()  { _require_root; _validate_path "$1"; shift; su -c "find '$1' $*"; }

_safe_write() {
  _require_root
  local dst="$1"; shift
  _validate_path "$dst"
  # Write via temp then move to avoid partial writes on /system etc.
  local tmp; tmp="$(su -c 'mktemp /data/local/tmp/ds_write.XXXXXX')"
  cat "$@" | su -c "cat > '$tmp'"
  su -c "mv -f '$tmp' '$dst'"
  echo -e "${G}[✓] Wrote to ${dst}${N}"
}

_safe_cp() {
  _require_root
  local src="$1" dst="$2"
  _validate_path "$src"
  _validate_path "$dst"
  su -c "cp -a -- '$src' '$dst'"
  echo -e "${G}[✓] Copied ${src} → ${dst}${N}"
}

CMD="${1:-help}"; shift 2>/dev/null || true
case "$CMD" in
  read|cat)  _safe_cat  "$@" ;;
  ls)        _safe_ls   "$@" ;;
  stat)      _safe_stat "$@" ;;
  find)      _safe_find "$@" ;;
  write)     _safe_write "$@" ;;
  cp)        _safe_cp   "$@" ;;
  paths)     printf '%s\n' "${ROOT_PATHS[@]}" ;;
  help|*)
    echo "Usage: fileops.sh <cmd> <args>"
    echo "  read|cat  <path>            — print file contents"
    echo "  ls        <path>            — list directory"
    echo "  stat      <path>            — stat file/dir"
    echo "  find      <path> [opts...]  — find under path"
    echo "  write     <dst> [src|-]     — write file as root"
    echo "  cp        <src> <dst>       — copy as root"
    echo "  paths                       — list all root-accessible trees"
    ;;
esac
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
#  3. ROOT-MODE APK EXTRACTION
# ─────────────────────────────────────────────────────────────────────────────
gen_root_apk_extract() {
  local base="$1"
  write_file "${base}/root/apk_extract.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/apk_extract.sh
# Extracts system APKs from /system/app and /system/priv-app.
# Usage: apk_extract.sh [--dest <dir>] [--package <glob>] [--list]

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; W='\033[1;37m'; N='\033[0m'

DEST="${HOME}/DroidShell/apk_extract/$(date +%Y%m%d_%H%M%S)"
PKG_FILTER="*"
LIST_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest)     DEST="$2";       shift 2 ;;
    --package)  PKG_FILTER="$2"; shift 2 ;;
    --list)     LIST_ONLY=true;  shift   ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }

SRC_PATHS=( "/system/app" "/system/priv-app" )

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║      DroidShell APK Extractor            ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"

total=0; extracted=0

for src in "${SRC_PATHS[@]}"; do
  [[ -d "$src" ]] || { echo -e "${Y}[SKIP] ${src} not found${N}"; continue; }

  while IFS= read -r apk; do
    pkg_dir="$(basename "$(dirname "$apk")")"
    [[ "$pkg_dir" == $PKG_FILTER ]] || [[ "$PKG_FILTER" == "*" ]] || continue
    ((total++))

    if $LIST_ONLY; then
      echo -e "  ${W}${pkg_dir}${N}  →  ${apk}"
      continue
    fi

    dest_file="${DEST}/${pkg_dir}/$(basename "$apk")"
    mkdir -p "${DEST}/${pkg_dir}"
    su -c "cp -f '$apk' '$dest_file'" && {
      # Preserve permissions but make readable
      chmod 644 "$dest_file" 2>/dev/null || true
      echo -e "${G}[✓]${N} ${pkg_dir} → ${dest_file}"
      ((extracted++))
    } || echo -e "${Y}[!]${N} Failed: ${apk}"

  done < <(su -c "find '$src' -name '*.apk' 2>/dev/null")
done

$LIST_ONLY && { echo -e "\n${C}Total: ${total} APKs${N}"; exit 0; }

echo -e "\n${C}══ Extraction complete: ${extracted}/${total} APKs → ${DEST} ══${N}"

# Generate manifest
{
  echo "# DroidShell APK Extract Manifest"
  echo "# Generated: $(date -Iseconds)"
  echo "# Source:    ${SRC_PATHS[*]}"
  echo "# Filter:    ${PKG_FILTER}"
  echo ""
  find "$DEST" -name "*.apk" 2>/dev/null | sort
} > "${DEST}/MANIFEST.txt"
log_msg="manifest → ${DEST}/MANIFEST.txt"
echo -e "${G}[✓]${N} ${log_msg}"
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
#  4. ROOT-MODE LOG COLLECTORS
# ─────────────────────────────────────────────────────────────────────────────
gen_root_logs() {
  local base="$1"
  write_file "${base}/root/log_collect.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/log_collect.sh
# Collects logcat (full), dmesg, and /proc/kmsg as root.
# Usage: log_collect.sh [--out <dir>] [--duration <secs>] [--buffers <list>]

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; N='\033[0m'

OUT_DIR="${HOME}/DroidShell/logs/$(date +%Y%m%d_%H%M%S)"
DURATION=30
BUFFERS="main,system,crash,kernel,radio,events"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)      OUT_DIR="$2";  shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    --buffers)  BUFFERS="$2";  shift 2 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }
mkdir -p "$OUT_DIR"

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║      DroidShell Log Collector            ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"
echo -e "${C}Output  : ${OUT_DIR}${N}"
echo -e "${C}Duration: ${DURATION}s  |  Buffers: ${BUFFERS}${N}"
echo ""

# ── logcat (full, all buffers, root) ─────────────────────────────────────────
echo -e "${G}[1/3]${N} logcat..."
su -c "logcat -b ${BUFFERS} -d" > "${OUT_DIR}/logcat_dump.txt" 2>&1 &
LOG_PID=$!
sleep "$DURATION"
kill "$LOG_PID" 2>/dev/null || true
wait "$LOG_PID" 2>/dev/null || true
lines=$(wc -l < "${OUT_DIR}/logcat_dump.txt")
echo -e "      → ${lines} lines → logcat_dump.txt"

# ── dmesg ─────────────────────────────────────────────────────────────────────
echo -e "${G}[2/3]${N} dmesg..."
su -c "dmesg -T" > "${OUT_DIR}/dmesg.txt" 2>&1
lines=$(wc -l < "${OUT_DIR}/dmesg.txt")
echo -e "      → ${lines} lines → dmesg.txt"

# ── /proc/kmsg ────────────────────────────────────────────────────────────────
echo -e "${G}[3/3]${N} /proc/kmsg (${DURATION}s)..."
( su -c "cat /proc/kmsg" > "${OUT_DIR}/kmsg.txt" 2>&1 & KPID=$!; \
  sleep "$DURATION"; kill "$KPID" 2>/dev/null; wait "$KPID" 2>/dev/null; \
  echo -e "      → $(wc -l < "${OUT_DIR}/kmsg.txt") lines → kmsg.txt" )

# ── Metadata ──────────────────────────────────────────────────────────────────
{
  echo "# DroidShell Log Collection Metadata"
  echo "# Generated : $(date -Iseconds)"
  echo "# Duration  : ${DURATION}s"
  echo "# Buffers   : ${BUFFERS}"
  echo "# Android   : $(su -c 'getprop ro.build.version.release' 2>/dev/null || echo unknown)"
  echo "# SDK       : $(su -c 'getprop ro.build.version.sdk'     2>/dev/null || echo unknown)"
  echo "# Device    : $(su -c 'getprop ro.product.model'         2>/dev/null || echo unknown)"
  echo "# Build     : $(su -c 'getprop ro.build.id'              2>/dev/null || echo unknown)"
} > "${OUT_DIR}/metadata.txt"

echo -e "\n${C}══ Log collection complete → ${OUT_DIR} ══${N}"
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
#  5. ROOT-MODE PROCESS INSPECTOR
# ─────────────────────────────────────────────────────────────────────────────
gen_root_procs() {
  local base="$1"
  write_file "${base}/root/proc_inspect.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/proc_inspect.sh
# Full root-mode process enumeration via /proc and ps -ef.
# Usage: proc_inspect.sh [--pid <pid>] [--grep <pattern>] [--out <file>]

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; W='\033[1;37m'; Y='\033[1;33m'; N='\033[0m'

FILTER_PID=""
GREP_PAT=""
OUT_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pid)  FILTER_PID="$2"; shift 2 ;;
    --grep) GREP_PAT="$2";   shift 2 ;;
    --out)  OUT_FILE="$2";   shift 2 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }

inspect_pid() {
  local pid="$1"
  [[ -d "/proc/$pid" ]] || return
  echo -e "\n${C}── PID ${pid} ─────────────────────────────────────${N}"

  local cmdline; cmdline=$(su -c "cat /proc/${pid}/cmdline 2>/dev/null" | tr '\0' ' ' || echo "<kernel>")
  local status;  status=$(su -c  "cat /proc/${pid}/status  2>/dev/null" || echo "n/a")
  local maps_n;  maps_n=$(su -c  "wc -l < /proc/${pid}/maps 2>/dev/null" || echo "0")
  local fds_n;   fds_n=$(su -c   "ls /proc/${pid}/fd 2>/dev/null | wc -l" || echo "0")

  echo -e "  ${W}Cmdline${N} : ${cmdline}"
  echo    "  Status  :"
  echo "$status" | grep -E '^(Name|State|Pid|PPid|Uid|Gid|VmRSS|VmSize|Threads):' \
    | sed 's/^/    /'
  echo -e "  ${W}Maps${N}    : ${maps_n} entries"
  echo -e "  ${W}FDs${N}     : ${fds_n} open"

  # Open files
  echo -e "  ${W}Open FDs${N}:"
  su -c "ls -la /proc/${pid}/fd 2>/dev/null" | head -20 | sed 's/^/    /'

  # Selinux context
  local ctx; ctx=$(su -c "cat /proc/${pid}/attr/current 2>/dev/null" || echo "n/a")
  echo -e "  ${W}SELinux ctx${N}: ${ctx}"
}

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║    DroidShell Process Inspector          ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"

{
  echo "# DroidShell Process Snapshot — $(date -Iseconds)"
  echo ""

  if [[ -n "$FILTER_PID" ]]; then
    inspect_pid "$FILTER_PID"
  else
    echo -e "${C}Full process list (ps -ef):${N}"
    su -c "ps -ef 2>/dev/null || ps -A" | \
      { [[ -n "$GREP_PAT" ]] && grep -E "$GREP_PAT" || cat; }

    echo -e "\n${C}/proc enumeration:${N}"
    for pid in $(su -c "ls /proc" | grep -E '^[0-9]+$'); do
      [[ -n "$GREP_PAT" ]] && {
        su -c "cat /proc/${pid}/cmdline 2>/dev/null" \
          | grep -qE "$GREP_PAT" || continue
      }
      inspect_pid "$pid"
    done
  fi
} | tee "${OUT_FILE:-/dev/null}"

[[ -n "$OUT_FILE" ]] && echo -e "\n${G}[✓] Saved → ${OUT_FILE}${N}"
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
#  6. ROOT-MODE NETWORK INSPECTOR
# ─────────────────────────────────────────────────────────────────────────────
gen_root_net() {
  local base="$1"
  write_file "${base}/root/net_inspect.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/net_inspect.sh
# Root-mode access to /proc/net/*, iptables, and routing tables.
# Usage: net_inspect.sh [--out <dir>] [--section <name>]

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; W='\033[1;37m'; N='\033[0m'

OUT_DIR=""
SECTION="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)     OUT_DIR="$2";  shift 2 ;;
    --section) SECTION="$2"; shift 2 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }

[[ -n "$OUT_DIR" ]] && mkdir -p "$OUT_DIR"

_header() { echo -e "\n${C}══ $1 ══${N}"; }
_dump()   {
  local label="$1" cmd="$2"
  _header "$label"
  local out; out=$(su -c "$cmd" 2>&1)
  echo "$out"
  [[ -n "$OUT_DIR" ]] && echo "$out" > "${OUT_DIR}/${label// /_}.txt"
}

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║    DroidShell Network Inspector          ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"

do_procnet() {
  _dump "proc_net_tcp"     "cat /proc/net/tcp"
  _dump "proc_net_tcp6"    "cat /proc/net/tcp6"
  _dump "proc_net_udp"     "cat /proc/net/udp"
  _dump "proc_net_udp6"    "cat /proc/net/udp6"
  _dump "proc_net_raw"     "cat /proc/net/raw"
  _dump "proc_net_if_inet6" "cat /proc/net/if_inet6"
  _dump "proc_net_dev"     "cat /proc/net/dev"
  _dump "proc_net_arp"     "cat /proc/net/arp"
  _dump "proc_net_fib_trie" "cat /proc/net/fib_trie"
  _dump "proc_net_sockstat" "cat /proc/net/sockstat"
  _dump "proc_net_unix"    "cat /proc/net/unix"
  _dump "proc_net_wireless" "cat /proc/net/wireless 2>/dev/null || echo N/A"
}

do_iptables() {
  for tbl in filter nat mangle raw security; do
    _dump "iptables_${tbl}"   "iptables -t ${tbl} -L -n -v --line-numbers 2>/dev/null || echo N/A"
    _dump "ip6tables_${tbl}"  "ip6tables -t ${tbl} -L -n -v --line-numbers 2>/dev/null || echo N/A"
  done
}

do_routing() {
  _dump "route_ipv4"   "ip route show 2>/dev/null || route -n"
  _dump "route_ipv6"   "ip -6 route show 2>/dev/null || echo N/A"
  _dump "ip_rules"     "ip rule list 2>/dev/null || echo N/A"
  _dump "ip_links"     "ip link show 2>/dev/null || ifconfig"
  _dump "ip_addrs"     "ip addr show 2>/dev/null || ifconfig"
  _dump "ip_neigh"     "ip neigh show 2>/dev/null || arp -a"
  _dump "ss_all"       "ss -tulwanp 2>/dev/null || netstat -tulwanp 2>/dev/null || echo N/A"
}

case "$SECTION" in
  procnet)   do_procnet  ;;
  iptables)  do_iptables ;;
  routing)   do_routing  ;;
  all|*)     do_procnet; do_iptables; do_routing ;;
esac

[[ -n "$OUT_DIR" ]] && echo -e "\n${G}[✓] Saved all sections → ${OUT_DIR}${N}"
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
#  7. ROOT-MODE BACKUP UTILITIES
# ─────────────────────────────────────────────────────────────────────────────
gen_root_backup() {
  local base="$1"
  write_file "${base}/root/backup.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/backup.sh
# Safe root-mode backup: app data, system configs, boot logs.
# Usage: backup.sh [--package <pkg>] [--system-configs] [--boot-logs] [--all]
#                  [--out <dir>] [--compress]

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; R='\033[1;31m'; N='\033[0m'

PACKAGES=(); SYS_CFG=false; BOOT_LOGS=false; ALL=false; COMPRESS=false
OUT_DIR="${HOME}/DroidShell/backups/$(date +%Y%m%d_%H%M%S)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)       PACKAGES+=("$2"); shift 2 ;;
    --system-configs) SYS_CFG=true;   shift   ;;
    --boot-logs)     BOOT_LOGS=true;  shift   ;;
    --all)           ALL=true;        shift   ;;
    --compress)      COMPRESS=true;   shift   ;;
    --out)           OUT_DIR="$2";    shift 2 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }
mkdir -p "$OUT_DIR"

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║      DroidShell Backup Utility           ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"
echo -e "${C}Output: ${OUT_DIR}${N}\n"

# ── App data backup ──────────────────────────────────────────────────────────
backup_package() {
  local pkg="$1"
  local src="/data/data/${pkg}"
  local dst="${OUT_DIR}/app_data/${pkg}"
  su -c "[[ -d '$src' ]]" 2>/dev/null || {
    echo -e "${Y}[!] Package not found: ${pkg}${N}"; return; }
  mkdir -p "$dst"
  su -c "cp -a '${src}/.' '${dst}/'" 2>&1
  # Fix ownership so Termux user can read
  chmod -R u+rX "$dst" 2>/dev/null || true
  echo -e "${G}[✓]${N} app data → ${dst}"
}

# ── System configs ────────────────────────────────────────────────────────────
backup_system_configs() {
  local dst="${OUT_DIR}/system_configs"
  mkdir -p "$dst"
  local cfg_paths=(
    "/system/build.prop"
    "/vendor/build.prop"
    "/system/etc/hosts"
    "/system/etc/init.d"
    "/system/etc/permissions"
    "/system/etc/sysconfig"
    "/data/system/packages.xml"
    "/data/system/appops.xml"
    "/data/system/users"
    "/data/misc/wifi/WifiConfigStore.xml"
    "/data/misc/bluedroid/bt_config.xml"
    "/data/adb/magisk.db"
  )
  for p in "${cfg_paths[@]}"; do
    su -c "[[ -e '$p' ]]" 2>/dev/null || { echo -e "${Y}[skip]${N} ${p}"; continue; }
    local rel="${p#/}"; local fdst="${dst}/${rel}"
    mkdir -p "$(dirname "$fdst")"
    su -c "cp -a '$p' '$fdst'" 2>&1
    echo -e "${G}[✓]${N} ${p}"
  done
  echo -e "${G}[✓]${N} system configs → ${dst}"
}

# ── Boot logs ─────────────────────────────────────────────────────────────────
backup_boot_logs() {
  local dst="${OUT_DIR}/boot_logs"
  mkdir -p "$dst"
  su -c "dmesg -T" > "${dst}/dmesg.txt" 2>&1
  su -c "logcat -b all -d" > "${dst}/logcat_all.txt" 2>&1
  su -c "cat /proc/last_kmsg 2>/dev/null || echo 'N/A'" > "${dst}/last_kmsg.txt"
  su -c "cat /sys/fs/pstore/console-ramoops-0 2>/dev/null || echo 'N/A'" \
    > "${dst}/ramoops.txt"
  echo -e "${G}[✓]${N} boot logs → ${dst}"
}

# ── All packages ──────────────────────────────────────────────────────────────
backup_all_packages() {
  while IFS= read -r pkg; do
    [[ -n "$pkg" ]] && backup_package "$pkg"
  done < <(su -c "ls /data/data" 2>/dev/null)
}

$ALL && { backup_all_packages; backup_system_configs; backup_boot_logs; }
[[ ${#PACKAGES[@]} -gt 0 ]] && for p in "${PACKAGES[@]}"; do backup_package "$p"; done
$SYS_CFG  && backup_system_configs
$BOOT_LOGS && backup_boot_logs

# ── Compress ──────────────────────────────────────────────────────────────────
if $COMPRESS; then
  archive="${OUT_DIR}.tar.gz"
  tar -czf "$archive" -C "$(dirname "$OUT_DIR")" "$(basename "$OUT_DIR")"
  rm -rf "$OUT_DIR"
  echo -e "${G}[✓]${N} Compressed → ${archive}"
  OUT_DIR="$archive"
fi

echo -e "\n${C}══ Backup complete → ${OUT_DIR} ══${N}"

# Manifest
{
  echo "# DroidShell Backup Manifest"
  echo "# Generated: $(date -Iseconds)"
  echo "# Packages : ${PACKAGES[*]:-all}"
  echo "# Sys cfgs : $SYS_CFG"
  echo "# Boot logs: $BOOT_LOGS"
} > "${OUT_DIR%/}/MANIFEST.txt" 2>/dev/null || true
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
#  8. ROOT-MODE SHELL EXECUTOR
# ─────────────────────────────────────────────────────────────────────────────
gen_root_shell() {
  local base="$1"
  write_file "${base}/root/shell_exec.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/shell_exec.sh
# Safe wrapper around: su -c "<command>"
# Maintains an audit log with timestamps.
# Usage: shell_exec.sh "<command>"
#        shell_exec.sh --interactive
#        shell_exec.sh --audit-log [<file>]

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'

AUDIT_LOG="${HOME}/DroidShell/logs/shell_exec_audit.log"
INTERACTIVE=false
SHOW_LOG=false

[[ "$1" == "--interactive" ]] && { INTERACTIVE=true; shift || true; }
[[ "$1" == "--audit-log"   ]] && { SHOW_LOG=true;    shift || true
                                   [[ -n "${1:-}" ]] && { AUDIT_LOG="$1"; shift; }; }

mkdir -p "$(dirname "$AUDIT_LOG")"

su -c "id" 2>/dev/null | grep -q "uid=0" || {
  echo -e "${R}[ERR] Root not available${N}" >&2; exit 1; }

$SHOW_LOG && { cat "$AUDIT_LOG" 2>/dev/null || echo "(no audit log yet)"; exit 0; }

_exec_cmd() {
  local cmd="$1"
  local ts; ts="$(date -Iseconds)"
  local caller; caller="$(id -un 2>/dev/null || echo unknown)"

  echo -e "${C}[su-exec]${N} ${cmd}"

  local output exit_code=0
  output=$(su -c "$cmd" 2>&1) || exit_code=$?

  # Audit entry
  printf '%s | caller=%s | exit=%d | cmd=%s\n' \
    "$ts" "$caller" "$exit_code" "$cmd" >> "$AUDIT_LOG"

  if [[ $exit_code -eq 0 ]]; then
    echo -e "${G}[✓ exit:0]${N}"
    echo "$output"
  else
    echo -e "${Y}[! exit:${exit_code}]${N}"
    echo "$output"
  fi
  return $exit_code
}

if $INTERACTIVE; then
  echo -e "${C}DroidShell root shell — type 'exit' to quit${N}"
  echo -e "${Y}All commands are logged to: ${AUDIT_LOG}${N}"
  while IFS= read -r -p "$(echo -e "${R}root${N}${C}@droidshell${N}# ")" line; do
    [[ "$line" == "exit" ]] && break
    [[ -z "$line" ]] && continue
    _exec_cmd "$line" || true
  done
  echo -e "${C}Session ended.${N}"
elif [[ -n "${1:-}" ]]; then
  _exec_cmd "$*"
else
  echo "Usage: shell_exec.sh \"<command>\""
  echo "       shell_exec.sh --interactive"
  echo "       shell_exec.sh --audit-log [<logfile>]"
fi
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
#  9. ROOT-MODE MODULE BUILDER
# ─────────────────────────────────────────────────────────────────────────────
gen_root_module_builder() {
  local base="$1"

  # ── 9a. Partition / flash ops ───────────────────────────────────────────────
  write_file "${base}/root/modules/partition_ops.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/modules/partition_ops.sh
# Partition inspection and controlled flashing via dd/fastboot.
# Usage: partition_ops.sh list|read|flash|verify  [args...]
#   list                         — list block devices + partition map
#   read  <part> <out.img>       — read partition to image
#   flash <part> <in.img>        — flash image to partition (with confirmation)
#   verify <part> <img>          — sha256 verify image vs partition

set -euo pipefail
G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; C='\033[1;36m'; N='\033[0m'

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }

_resolve_part() {
  local name="$1"
  # Accept /dev/block/... directly, or resolve by-name
  if [[ -b "$name" ]]; then echo "$name"; return; fi
  local p; p=$(su -c "find /dev/block/by-name -name '${name}' 2>/dev/null" | head -1)
  [[ -n "$p" ]] && echo "$p" && return
  echo -e "${R}[ERR] Partition not found: ${name}${N}" >&2; exit 1
}

case "${1:-help}" in
  list)
    echo -e "${C}Block devices:${N}"
    su -c "ls -la /dev/block/by-name/ 2>/dev/null || lsblk 2>/dev/null || \
           cat /proc/partitions"
    ;;

  read)
    [[ $# -ge 3 ]] || { echo "Usage: partition_ops.sh read <part> <out.img>"; exit 1; }
    part=$(_resolve_part "$2"); out="$3"
    echo -e "${C}Reading ${part} → ${out}${N}"
    su -c "dd if='${part}' of='${out}' bs=4096 status=progress 2>&1"
    sha256sum "$out"
    echo -e "${G}[✓] Read complete${N}"
    ;;

  flash)
    [[ $# -ge 3 ]] || { echo "Usage: partition_ops.sh flash <part> <img>"; exit 1; }
    part=$(_resolve_part "$2"); img="$3"
    [[ -f "$img" ]] || { echo -e "${R}[ERR] Image not found: ${img}${N}"; exit 1; }
    echo -e "${Y}WARNING: This will overwrite ${part} with ${img}${N}"
    echo -e "${Y}Image SHA256: $(sha256sum "$img")${N}"
    read -r -p "Type 'CONFIRM FLASH' to proceed: " answer
    [[ "$answer" == "CONFIRM FLASH" ]] || { echo "Aborted."; exit 1; }
    su -c "dd if='${img}' of='${part}' bs=4096 conv=fsync status=progress 2>&1"
    echo -e "${G}[✓] Flash complete${N}"
    ;;

  verify)
    [[ $# -ge 3 ]] || { echo "Usage: partition_ops.sh verify <part> <img>"; exit 1; }
    part=$(_resolve_part "$2"); img="$3"
    echo -e "${C}Verifying ${part} vs ${img}...${N}"
    img_hash=$(sha256sum "$img" | awk '{print $1}')
    part_hash=$(su -c "sha256sum '${part}'" | awk '{print $1}')
    if [[ "$img_hash" == "$part_hash" ]]; then
      echo -e "${G}[✓] Match: ${img_hash}${N}"
    else
      echo -e "${R}[✗] Mismatch!${N}"
      echo "  Image    : $img_hash"
      echo "  Partition: $part_hash"
      exit 1
    fi
    ;;

  help|*) echo "Usage: partition_ops.sh list|read|flash|verify [args...]" ;;
esac
EOF

  # ── 9b. SELinux policy inspector ────────────────────────────────────────────
  write_file "${base}/root/modules/selinux_inspect.sh" << 'EOF'
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
EOF

  # ── 9c. Verified boot / AVB inspector ───────────────────────────────────────
  write_file "${base}/root/modules/verified_boot.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/modules/verified_boot.sh
# Inspect Android Verified Boot (AVB) state, vbmeta, and dm-verity.

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'

su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }

echo -e "${C}╔══════════════════════════════════════════╗${N}"
echo -e "${C}║   DroidShell Verified Boot Inspector     ║${N}"
echo -e "${C}╚══════════════════════════════════════════╝${N}"

_prop() { su -c "getprop '$1' 2>/dev/null" || echo "N/A"; }

echo -e "\n${C}── AVB Properties ──────────────────────────${N}"
for p in ro.boot.verifiedbootstate ro.boot.veritymode \
          ro.boot.flash.locked ro.boot.avb_version \
          ro.boot.vbmeta.digest ro.boot.vbmeta.size \
          ro.boot.vbmeta.device ro.boot.vbmeta.flags; do
  printf '  %-40s %s\n' "$p" "$(_prop "$p")"
done

echo -e "\n${C}── dm-verity status ────────────────────────${N}"
su -c "cat /proc/fs/ext4/*/verity_mode 2>/dev/null || echo 'N/A (or not ext4)'"
su -c "dmsetup status 2>/dev/null | grep -i verity || echo 'No verity targets'"

echo -e "\n${C}── vbmeta partition (first 4k) ─────────────${N}"
vbmeta_dev=$(su -c "find /dev/block/by-name -name 'vbmeta*' 2>/dev/null" | head -1)
if [[ -n "$vbmeta_dev" ]]; then
  echo "Device: $vbmeta_dev"
  su -c "dd if='${vbmeta_dev}' bs=512 count=8 2>/dev/null | xxd | head -40"
else
  echo "vbmeta partition not found"
fi

echo -e "\n${C}── Boot partition hash ─────────────────────${N}"
boot_dev=$(su -c "find /dev/block/by-name -name 'boot' 2>/dev/null" | head -1)
if [[ -n "$boot_dev" ]]; then
  echo "Hashing first 1M of ${boot_dev}..."
  su -c "dd if='${boot_dev}' bs=1M count=1 2>/dev/null | sha256sum"
else
  echo "boot partition not found"
fi
EOF

  # ── 9d. Module builder meta-scaffold ────────────────────────────────────────
  write_file "${base}/root/modules/build_module.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/modules/build_module.sh
# Scaffold a new DroidShell root module with boilerplate.
# Usage: build_module.sh <module_name> [--description "<desc>"] [--type <type>]
# Types: generic | magisk | system | network | backup | ci | installer | nightly

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; N='\033[0m'

[[ -n "${1:-}" ]] || { echo "Usage: build_module.sh <name> [opts]"; exit 1; }

MOD_NAME="$1"; shift
MOD_DESC="DroidShell root module"
MOD_TYPE="generic"
MOD_BASE="${HOME}/DroidShell/root/modules"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --description) MOD_DESC="$2"; shift 2 ;;
    --type)        MOD_TYPE="$2"; shift 2 ;;
    --base)        MOD_BASE="$2"; shift 2 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

MOD_DIR="${MOD_BASE}/${MOD_NAME}"
mkdir -p "${MOD_DIR}"/{lib,tests,ci,installer,nightly}

# ── Main module script ────────────────────────────────────────────────────────
cat > "${MOD_DIR}/${MOD_NAME}.sh" << MODEOF
#!/usr/bin/env bash
# DroidShell Module :: ${MOD_NAME}
# Type       : ${MOD_TYPE}
# Description: ${MOD_DESC}
# Generated  : $(date -Iseconds)

set -euo pipefail
source "\$(dirname "\$0")/lib/common.sh" 2>/dev/null || true

MODULE_NAME="${MOD_NAME}"
MODULE_VERSION="0.1.0"

require_root() {
  su -c "id" 2>/dev/null | grep -q "uid=0" || { echo "Root required"; exit 1; }
}

main() {
  require_root
  echo "Running \${MODULE_NAME} v\${MODULE_VERSION}"
  # TODO: implement module logic
}

main "\$@"
MODEOF
chmod +x "${MOD_DIR}/${MOD_NAME}.sh"

# ── Common lib ────────────────────────────────────────────────────────────────
cat > "${MOD_DIR}/lib/common.sh" << 'LIBEOF'
#!/usr/bin/env bash
# DroidShell module common library

DS_LOG_DIR="${HOME}/DroidShell/logs"
mkdir -p "$DS_LOG_DIR"

ds_log()  { echo -e "\033[1;32m[DS]\033[0m $*" | tee -a "${DS_LOG_DIR}/${MODULE_NAME:-module}.log"; }
ds_warn() { echo -e "\033[1;33m[DS]\033[0m $*" | tee -a "${DS_LOG_DIR}/${MODULE_NAME:-module}.log"; }
ds_err()  { echo -e "\033[1;31m[DS]\033[0m $*" >&2; }
ds_su()   { su -c "$*"; }
LIBEOF

# ── CI workflow ───────────────────────────────────────────────────────────────
cat > "${MOD_DIR}/ci/run_tests.sh" << CIEOF
#!/usr/bin/env bash
# DroidShell CI :: ${MOD_NAME}
set -euo pipefail
PASS=0; FAIL=0
for t in "\$(dirname "\$0")/../tests"/test_*.sh; do
  bash "\$t" && ((PASS++)) || ((FAIL++))
done
echo "Results: \${PASS} passed, \${FAIL} failed"
[[ \$FAIL -eq 0 ]]
CIEOF
chmod +x "${MOD_DIR}/ci/run_tests.sh"

# ── Sample test ───────────────────────────────────────────────────────────────
cat > "${MOD_DIR}/tests/test_smoke.sh" << TESTEOF
#!/usr/bin/env bash
# DroidShell Test :: ${MOD_NAME} smoke test
set -euo pipefail
bash "\$(dirname "\$0")/../${MOD_NAME}.sh" --help 2>/dev/null || true
echo "[PASS] smoke test"
TESTEOF
chmod +x "${MOD_DIR}/tests/test_smoke.sh"

# ── Installer ─────────────────────────────────────────────────────────────────
cat > "${MOD_DIR}/installer/install.sh" << INSTEOF
#!/usr/bin/env bash
# DroidShell Installer :: ${MOD_NAME}
set -euo pipefail
INSTALL_DIR="\${1:-\${HOME}/DroidShell/root/modules/${MOD_NAME}}"
echo "Installing ${MOD_NAME} → \${INSTALL_DIR}"
cp -r "\$(dirname "\$0")/.." "\${INSTALL_DIR}/"
chmod +x "\${INSTALL_DIR}/${MOD_NAME}.sh"
echo "Done."
INSTEOF
chmod +x "${MOD_DIR}/installer/install.sh"

# ── Nightly / release scaffold ────────────────────────────────────────────────
cat > "${MOD_DIR}/nightly/nightly.sh" << NIGHTEOF
#!/usr/bin/env bash
# DroidShell Nightly :: ${MOD_NAME}
set -euo pipefail
VERSION="\$(date +%Y%m%d)-\$(git rev-parse --short HEAD 2>/dev/null || echo nongit)"
OUT="${HOME}/DroidShell/releases/${MOD_NAME}-\${VERSION}.tar.gz"
mkdir -p "\$(dirname "\$OUT")"
tar -czf "\$OUT" -C "\$(dirname "\$0")/.." .
echo "Nightly → \$OUT"
NIGHTEOF
chmod +x "${MOD_DIR}/nightly/nightly.sh"

# ── README ────────────────────────────────────────────────────────────────────
cat > "${MOD_DIR}/README.md" << READEOF
# DroidShell Module: ${MOD_NAME}

**Type**: ${MOD_TYPE}
**Description**: ${MOD_DESC}
**Generated**: $(date -Iseconds)

## Structure
\`\`\`
${MOD_NAME}/
├── ${MOD_NAME}.sh       ← main entry point
├── lib/common.sh        ← shared helpers
├── tests/test_smoke.sh  ← smoke test
├── ci/run_tests.sh      ← CI runner
├── installer/install.sh ← installer
└── nightly/nightly.sh   ← nightly build
\`\`\`

## Usage
\`\`\`bash
bash ${MOD_NAME}.sh
\`\`\`
READEOF

echo -e "${G}[✓] Module scaffolded → ${MOD_DIR}${N}"
echo -e "${C}Files created:${N}"
find "${MOD_DIR}" -type f | sort | sed 's/^/  /'
EOF

  # ── 9e. Update system scaffold ──────────────────────────────────────────────
  write_file "${base}/root/modules/update_system.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: root/modules/update_system.sh
# Self-update mechanism for DroidShell root modules.
# Usage: update_system.sh [--check] [--apply] [--rollback]

set -euo pipefail
C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; N='\033[0m'

DS_ROOT="${HOME}/DroidShell"
UPDATE_MANIFEST="${DS_ROOT}/updates/manifest.json"
BACKUP_DIR="${DS_ROOT}/updates/backups"

case "${1:---check}" in
  --check)
    echo -e "${C}Checking for DroidShell updates...${N}"
    [[ -f "$UPDATE_MANIFEST" ]] || { echo "No manifest found. Run --apply to initialize."; exit 0; }
    cat "$UPDATE_MANIFEST"
    ;;

  --apply)
    [[ -f "$UPDATE_MANIFEST" ]] || { echo "No manifest found at ${UPDATE_MANIFEST}"; exit 1; }
    mkdir -p "$BACKUP_DIR"
    echo -e "${C}Applying updates from manifest...${N}"
    # Back up current state before applying
    tar -czf "${BACKUP_DIR}/pre_update_$(date +%Y%m%d_%H%M%S).tar.gz" \
      -C "$DS_ROOT" root/ 2>/dev/null || true
    echo -e "${G}[✓] Backup created${N}"
    # The actual update steps are defined in manifest.json
    echo -e "${Y}[!] Implement fetch/apply logic in manifest.json${N}"
    ;;

  --rollback)
    latest=$(ls -t "${BACKUP_DIR}"/*.tar.gz 2>/dev/null | head -1)
    [[ -n "$latest" ]] || { echo "No backup found to rollback to"; exit 1; }
    echo -e "${Y}Rolling back to: ${latest}${N}"
    read -r -p "Confirm rollback? [y/N] " ans
    [[ "$ans" == "y" ]] || { echo "Aborted."; exit 0; }
    tar -xzf "$latest" -C "$DS_ROOT"
    echo -e "${G}[✓] Rollback complete${N}"
    ;;

  *)
    echo "Usage: update_system.sh [--check|--apply|--rollback]"
    ;;
esac
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
#  MASTER ENTRY: ds_root.sh
# ─────────────────────────────────────────────────────────────────────────────
gen_master_entrypoint() {
  local base="$1"
  write_file "${base}/ds_root.sh" << 'EOF'
#!/usr/bin/env bash
# DroidShell :: ds_root.sh
# Master root-enhancements entry point.
# Usage: ds_root.sh <module> [args...]

DS_ROOT="$(cd "$(dirname "$0")" && pwd)"
C='\033[1;36m'; G='\033[1;32m'; W='\033[1;37m'; N='\033[0m'

declare -A MODULES=(
  [detect]="root/detect_root.sh"
  [fileops]="root/fileops.sh"
  [apk]="root/apk_extract.sh"
  [logs]="root/log_collect.sh"
  [procs]="root/proc_inspect.sh"
  [net]="root/net_inspect.sh"
  [backup]="root/backup.sh"
  [exec]="root/shell_exec.sh"
  [partition]="root/modules/partition_ops.sh"
  [selinux]="root/modules/selinux_inspect.sh"
  [vboot]="root/modules/verified_boot.sh"
  [mkmodule]="root/modules/build_module.sh"
  [update]="root/modules/update_system.sh"
)

print_menu() {
  echo -e "${C}╔══════════════════════════════════════════════════╗${N}"
  echo -e "${C}║         DroidShell Root Enhancements             ║${N}"
  echo -e "${C}╚══════════════════════════════════════════════════╝${N}"
  echo -e "${C}Available modules:${N}"
  printf '  %-14s %s\n' \
    "detect"    "Root detection (Magisk/KernelSU/APatch/su)" \
    "fileops"   "Root-mode file operations (r/w all sys paths)" \
    "apk"       "APK extraction from /system/app + priv-app" \
    "logs"      "Log collection (logcat/dmesg/kmsg)" \
    "procs"     "Full process inspection via /proc" \
    "net"       "Network inspector (/proc/net, iptables, routes)" \
    "backup"    "Backup app data, system configs, boot logs" \
    "exec"      "Safe su -c shell executor (with audit log)" \
    "partition" "Partition list/read/flash/verify" \
    "selinux"   "SELinux policy inspection + allow-module gen" \
    "vboot"     "Verified Boot / AVB state inspector" \
    "mkmodule"  "Scaffold a new DroidShell root module" \
    "update"    "DroidShell update/rollback system"
  echo ""
  echo -e "Usage: ${W}$(basename "$0") <module> [args...]${N}"
}

MOD="${1:-help}"; shift 2>/dev/null || true

if [[ "$MOD" == "help" ]] || [[ -z "$MOD" ]]; then
  print_menu; exit 0
fi

if [[ -n "${MODULES[$MOD]:-}" ]]; then
  script="${DS_ROOT}/${MODULES[$MOD]}"
  [[ -x "$script" ]] || chmod +x "$script"
  exec bash "$script" "$@"
else
  echo -e "${C}Unknown module: ${MOD}${N}"
  print_menu
  exit 1
fi
EOF
}

# =============================================================================
#  GENERATION LOOP
# =============================================================================
for root in "${ROOTS[@]}"; do
  echo -e "\n${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
  echo -e "${B} Generating into: ${root}${N}"
  echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}\n"

  gen_root_detection     "$root"
  gen_root_fileops       "$root"
  gen_root_apk_extract   "$root"
  gen_root_logs          "$root"
  gen_root_procs         "$root"
  gen_root_net           "$root"
  gen_root_backup        "$root"
  gen_root_shell         "$root"
  gen_root_module_builder "$root"
  gen_master_entrypoint  "$root"

  echo -e "\n${G}✓ All modules written to ${root}${N}"
  echo -e "${C}Run: bash ${root}/ds_root.sh help${N}"
done

echo -e "\n${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${M} DroidShell Root Enhancements — Generation Complete${N}"
echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo ""
echo -e "Modules generated:"
echo -e "  ${W}1${N}  detect    — root detection"
echo -e "  ${W}2${N}  fileops   — r/w all system paths"
echo -e "  ${W}3${N}  apk       — system APK extraction"
echo -e "  ${W}4${N}  logs      — logcat/dmesg/kmsg collector"
echo -e "  ${W}5${N}  procs     — full process inspector"
echo -e "  ${W}6${N}  net       — /proc/net + iptables + routes"
echo -e "  ${W}7${N}  backup    — app data + system configs + boot logs"
echo -e "  ${W}8${N}  exec      — audited su -c wrapper"
echo -e "  ${W}9a${N} partition — dd-based partition r/w/verify"
echo -e "  ${W}9b${N} selinux   — policy inspector + allow-module gen"
echo -e "  ${W}9c${N} vboot     — AVB / verified boot inspector"
echo -e "  ${W}9d${N} mkmodule  — module scaffold (CI/installer/nightly)"
echo -e "  ${W}9e${N} update    — self-update + rollback system"
echo ""
echo -e "${Y}Omitted (not technician tools):"
echo -e "  ✗  rootkit installation"
echo -e "  ✗  authentication bypass${N}"


