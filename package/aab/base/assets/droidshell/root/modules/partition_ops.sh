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
