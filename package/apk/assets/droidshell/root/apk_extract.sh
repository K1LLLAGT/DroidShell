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
