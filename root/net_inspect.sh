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
