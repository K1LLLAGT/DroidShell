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
