#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(pwd)}"

TOTAL=0
OK=0
FAIL=0
WARN=0

red()   { printf "\033[31m%s\033[0m\n" "$1"; }
green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$1"; }

echo "=== DroidShell Repository Verification Suite ==="
echo "Root: $ROOT"
echo

# =========================
# ENVIRONMENT DETECTION + AUTO-INSTALL
# =========================
echo "=== Environment Detection ==="

detect_env() {
    if [[ -d "/data/data/com.termux/files/usr" ]]; then
        echo "termux"
        return
    fi

    if command -v apt >/dev/null 2>&1; then
        echo "debian"
        return
    fi

    if command -v pacman >/dev/null 2>&1; then
        echo "arch"
        return
    fi

    if command -v apk >/dev/null 2>&1; then
        echo "alpine"
        return
    fi

    if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
        echo "fedora"
        return
    fi

    if [[ "${OSTYPE:-}" == "darwin"* ]]; then
        echo "macos"
        return
    fi

    echo "unknown"
}

ENVIRONMENT=$(detect_env)
echo "Detected environment: $ENVIRONMENT"
echo

install_tool() {
    local tool="$1"

    case "$ENVIRONMENT" in

        termux)
            case "$tool" in
                jq) pkg install -y jq ;;
                yq) pkg install -y yq ;;
                shellcheck) pkg install -y shellcheck ;;
                markdownlint)
                    pkg install -y nodejs
                    npm install -g markdownlint-cli
                    ;;
                python3) pkg install -y python ;;
            esac
            ;;

        debian)
            sudo apt update
            case "$tool" in
                jq) sudo apt install -y jq ;;
                yq) sudo snap install yq || sudo apt install -y yq || true ;;
                shellcheck) sudo apt install -y shellcheck ;;
                markdownlint)
                    sudo apt install -y nodejs npm
                    sudo npm install -g markdownlint-cli
                    ;;
                python3) sudo apt install -y python3 ;;
            esac
            ;;

        arch)
            case "$tool" in
                jq) sudo pacman -S --noconfirm jq ;;
                yq) sudo pacman -S --noconfirm yq || true ;;
                shellcheck) sudo pacman -S --noconfirm shellcheck ;;
                markdownlint)
                    sudo pacman -S --noconfirm nodejs npm
                    sudo npm install -g markdownlint-cli
                    ;;
                python3) sudo pacman -S --noconfirm python ;;
            esac
            ;;

        alpine)
            case "$tool" in
                jq) sudo apk add jq ;;
                yq) sudo apk add yq || true ;;
                shellcheck) sudo apk add shellcheck ;;
                markdownlint)
                    sudo apk add nodejs npm
                    sudo npm install -g markdownlint-cli
                    ;;
                python3) sudo apk add python3 ;;
            esac
            ;;

        fedora)
            case "$tool" in
                jq) sudo dnf install -y jq ;;
                yq) sudo dnf install -y yq || true ;;
                shellcheck) sudo dnf install -y shellcheck ;;
                markdownlint)
                    sudo dnf install -y nodejs npm
                    sudo npm install -g markdownlint-cli
                    ;;
                python3) sudo dnf install -y python3 ;;
            esac
            ;;

        macos)
            case "$tool" in
                jq) brew install jq ;;
                yq) brew install yq ;;
                shellcheck) brew install shellcheck ;;
                markdownlint) npm install -g markdownlint-cli ;;
                python3) brew install python ;;
            esac
            ;;

        *)
            echo "[WARN] Unknown environment — cannot auto-install $tool"
            return 1
            ;;
    esac
}

echo "=== Checking required tools ==="
TOOLS=(jq yq shellcheck markdownlint python3)

for t in "${TOOLS[@]}"; do
    if ! command -v "$t" >/dev/null 2>&1; then
        echo "[MISSING] $t → installing..."
        if install_tool "$t"; then
            echo "[OK] Installed $t"
        else
            echo "[FAIL] Could not install $t"
            FAIL=$((FAIL+1))
        fi
    else
        echo "[OK] $t installed"
    fi
done

echo

# =========================
# CORE CHECK FUNCTIONS
# =========================
check_json() { jq empty "$1" >/dev/null 2>&1; }
check_yaml() { yq e '.' "$1" >/dev/null 2>&1; }
check_shell() { shellcheck "$1" >/dev/null 2>&1; }
check_python() { python3 -m py_compile "$1" >/dev/null 2>&1; }
check_markdown() { markdownlint "$1" >/dev/null 2>&1; }

check_shebang() {
    case "$1" in
        *.sh|*.py)
            head -n 1 "$1" | grep -Eq '^#!' || return 1
            ;;
    esac
}

check_permissions() {
    case "$1" in
        *.sh|*.py)
            [[ -x "$1" ]] || chmod +x "$1"
            ;;
    esac
}

# =========================
# MODULE VALIDATOR
# =========================
validate_module() {
    local dir="$1"
    local manifest="$dir/module.json"

    if [[ ! -f "$manifest" ]]; then
        yellow "[WARN] Module missing manifest: $dir"
        WARN=$((WARN+1))
        return
    fi

    if ! jq empty "$manifest" >/dev/null 2>&1; then
        red "[FAIL] Invalid module manifest: $manifest"
        FAIL=$((FAIL+1))
        return
    fi

    green "[OK] Module manifest valid: $manifest"
    OK=$((OK+1))
}

# =========================
# PLUGIN VALIDATOR
# =========================
validate_plugin() {
    local dir="$1"
    local manifest="$dir/manifest.json"
    local entry="$dir/plugin.sh"

    if [[ ! -f "$manifest" ]]; then
        red "[FAIL] Plugin missing manifest: $dir"
        FAIL=$((FAIL+1))
        return
    fi

    if ! jq empty "$manifest" >/dev/null 2>&1; then
        red "[FAIL] Invalid plugin manifest: $manifest"
        FAIL=$((FAIL+1))
        return
    fi

    if [[ ! -f "$entry" ]]; then
        red "[FAIL] Plugin missing entry script: $entry"
        FAIL=$((FAIL+1))
        return
    fi

    if ! shellcheck "$entry" >/dev/null 2>&1; then
        red "[FAIL] Plugin entry script failed lint: $entry"
        FAIL=$((FAIL+1))
        return
    fi

    green "[OK] Plugin valid: $dir"
    OK=$((OK+1))
}

# =========================
# SCRIPT ANALYZER
# =========================
analyze_script() {
    local file="$1"

    if ! check_shebang "$file"; then
        yellow "[WARN] Missing shebang: $file"
        WARN=$((WARN+1))
    fi

    if ! check_shell "$file"; then
        red "[FAIL] Shellcheck failed: $file"
        FAIL=$((FAIL+1))
        return
    fi

    if grep -qi "TODO" "$file"; then
        yellow "[WARN] TODO found in script: $file"
        WARN=$((WARN+1))
    fi

    green "[OK] Script valid: $file"
    OK=$((OK+1))
}

# =========================
# CI/CD WORKFLOW VALIDATOR
# =========================
validate_cicd() {
    local wf="$1"

    if ! yq e '.' "$wf" >/dev/null 2>&1; then
        red "[FAIL] Invalid GitHub Actions workflow: $wf"
        FAIL=$((FAIL+1))
        return
    fi

    if ! grep -q "runs-on:" "$wf"; then
        yellow "[WARN] Workflow missing runs-on: $wf"
        WARN=$((WARN+1))
    fi

    green "[OK] Workflow valid: $wf"
    OK=$((OK+1))
}

# =========================
# MAIN FILE SCAN
# =========================
echo "Scanning files..."
echo

while IFS= read -r -d '' file; do
    TOTAL=$((TOTAL+1))
    REL="${file#$ROOT/}"

    if file "$file" | grep -qE 'ELF|binary'; then
        green "[OK] BIN: $REL"
        OK=$((OK+1))
        continue
    fi

    if [[ ! -s "$file" ]]; then
        red "[FAIL] EMPTY: $REL"
        FAIL=$((FAIL+1))
        continue
    fi

    case "$file" in
        *.json)
            if check_json "$file"; then
                green "[OK] JSON: $REL"
                OK=$((OK+1))
            else
                red "[FAIL] JSON: $REL"
                FAIL=$((FAIL+1))
            fi
            ;;
        *.yaml|*.yml)
            if check_yaml "$file"; then
                green "[OK] YAML: $REL"
                OK=$((OK+1))
            else
                red "[FAIL] YAML: $REL"
                FAIL=$((FAIL+1))
            fi
            ;;
        *.sh)
            check_permissions "$file"
            analyze_script "$file"
            ;;
        *.py)
            check_permissions "$file"
            if check_python "$file"; then
                green "[OK] PY: $REL"
                OK=$((OK+1))
            else
                red "[FAIL] PY: $REL"
                FAIL=$((FAIL+1))
            fi
            ;;
        *.md)
            if check_markdown "$file"; then
                green "[OK] MD: $REL"
                OK=$((OK+1))
            else
                yellow "[WARN] MD Lint: $REL"
                WARN=$((WARN+1))
            fi
            ;;
        *)
            green "[OK] FILE: $REL"
            OK=$((OK+1))
            ;;
    esac

done < <(find "$ROOT" -type f -print0)

# =========================
# MODULE VALIDATION
# =========================
echo
echo "=== Validating Modules ==="
if [[ -d "$ROOT/modules" ]]; then
    find "$ROOT/modules" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | while read -r mod; do
        validate_module "$mod"
    done
else
    yellow "[WARN] No modules directory found at $ROOT/modules"
    WARN=$((WARN+1))
fi

# =========================
# PLUGIN VALIDATION
# =========================
echo
echo "=== Validating Plugins ==="
if [[ -d "$ROOT/plugins" ]]; then
    find "$ROOT/plugins" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | while read -r plug; do
        validate_plugin "$plug"
    done
else
    yellow "[WARN] No plugins directory found at $ROOT/plugins"
    WARN=$((WARN+1))
fi

# =========================
# CI/CD WORKFLOW VALIDATION
# =========================
echo
echo "=== Validating GitHub Actions Workflows ==="
if [[ -d "$ROOT/.github/workflows" ]]; then
    find "$ROOT/.github/workflows" \( -name "*.yml" -o -name "*.yaml" \) -type f 2>/dev/null | while read -r wf; do
        validate_cicd "$wf"
    done
else
    yellow "[WARN] No GitHub Actions workflows directory found at $ROOT/.github/workflows"
    WARN=$((WARN+1))
fi

# =========================
# SUMMARY
# =========================
echo
echo "=== SUMMARY ==="
echo "Total files: $TOTAL"
echo "OK:          $OK"
echo "WARN:        $WARN"
echo "FAIL:        $FAIL"
echo

if [[ $FAIL -gt 0 ]]; then
    red "Some checks failed."
    exit 1
else
    green "All checks passed successfully."
fi
