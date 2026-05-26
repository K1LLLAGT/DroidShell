#!/usr/bin/env bash
# DroidShell Repo Tools Bootstrap
# Generates:
#   - ds-repo-fix.sh   (auto-repair)
#   - ds-repo-tree.sh  (tree visualizer)
#   - ds-repo-diff.sh  (tree diff engine)

set -e

ROOT="/sdcard/DroidShell"
SCRIPTS="$ROOT/scripts"

mkdir -p "$SCRIPTS"

echo "[DroidShell] Installing Repo Tools..."


###############################################
# 1. ds-repo-fix.sh — auto-repair system
###############################################
cat > "$SCRIPTS/ds-repo-fix.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Repo Auto-Repair
# Creates missing core directories and stubs critical files.

set -e

ROOT="/sdcard/DroidShell"

echo "[DroidShell] Running Repo Auto-Repair..."

# Core dirs
dirs=(
  scripts
  docs
  docs/man
  supervisor/state
  supervisor/log
  fsdb
  net
  etc/services
  modules
  source
  tools
  site
  sdk
  .runtime
  .data
  .env-registry
  .pkg-db
)

for d in "${dirs[@]}"; do
  if [ ! -d "$ROOT/$d" ]; then
    mkdir -p "$ROOT/$d"
    echo "  [MKDIR] $d"
  else
    echo "  [OK]    $d"
  fi
done

# Stub critical docs if missing
stub_doc() {
  local f="$1"
  local title="$2"
  if [ ! -f "$ROOT/docs/$f" ]; then
    echo "# $title" > "$ROOT/docs/$f"
    echo "  [STUB] docs/$f"
  fi
}

stub_doc "OS-DIRECTORY-SPEC.md" "DroidShell OS Directory Specification"
stub_doc "DEVELOPER-HANDBOOK.md" "DroidShell Developer Handbook"
stub_doc "RUNTIME-ARCHITECTURE.md" "DroidShell Runtime Architecture"
stub_doc "MANPAGE-INDEX.md" "DroidShell Manpage Index"

# Ensure ds-docs-bootstrap.sh exists hint
if [ ! -f "$ROOT/scripts/ds-docs-bootstrap.sh" ]; then
  echo "  [WARN] ds-docs-bootstrap.sh missing (docs will be minimal)"
fi

echo "[DroidShell] Repo Auto-Repair complete."
EOF

chmod +x "$SCRIPTS/ds-repo-fix.sh"
echo "[DroidShell] ds-repo-fix.sh installed."


###############################################
# 2. ds-repo-tree.sh — repo tree visualizer
###############################################
cat > "$SCRIPTS/ds-repo-tree.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Repo Tree Visualizer
# Prints a tree-like view of the repo.

set -e

ROOT="/sdcard/DroidShell"
OUT="$ROOT/ds-tree.txt"

echo "[DroidShell] Generating repo tree at $OUT..."

(
  cd "$ROOT"
  # Simple tree using find + sed
  find . -print | sed 's|^\./||' | sort
) > "$OUT"

cat "$OUT"
EOF

chmod +x "$SCRIPTS/ds-repo-tree.sh"
echo "[DroidShell] ds-repo-tree.sh installed."


###############################################
# 3. ds-repo-diff.sh — repo diff engine
###############################################
cat > "$SCRIPTS/ds-repo-diff.sh" <<'EOF'
#!/usr/bin/env bash
# DroidShell Repo Diff Engine
# Compares current tree against a saved snapshot.

set -e

ROOT="/sdcard/DroidShell"
SNAP_DIR="$ROOT/.repo-snapshots"
mkdir -p "$SNAP_DIR"

cmd="$1"
name="${2:-default}"

usage() {
  echo "Usage:"
  echo "  ds-repo-diff.sh snapshot [name]"
  echo "  ds-repo-diff.sh diff [name]"
  exit 1
}

[ -z "$cmd" ] && usage

snapshot_file="$SNAP_DIR/$name.tree"

case "$cmd" in
  snapshot)
    echo "[DroidShell] Creating snapshot: $snapshot_file"
    (
      cd "$ROOT"
      find . -print | sed 's|^\./||' | sort
    ) > "$snapshot_file"
    echo "[DroidShell] Snapshot saved."
    ;;
  diff)
    if [ ! -f "$snapshot_file" ]; then
      echo "[ERR] Snapshot not found: $snapshot_file"
      exit 1
    fi
    echo "[DroidShell] Comparing current tree to snapshot: $name"
    current="$(mktemp)"
    (
      cd "$ROOT"
      find . -print | sed 's|^\./||' | sort
    ) > "$current"

    echo "---- Added ----"
    comm -13 "$snapshot_file" "$current" || true
    echo
    echo "---- Removed ----"
    comm -23 "$snapshot_file" "$current" || true

    rm -f "$current"
    ;;
  *)
    usage
    ;;
esac
EOF

chmod +x "$SCRIPTS/ds-repo-diff.sh"
echo "[DroidShell] ds-repo-diff.sh installed."


###############################################
# DONE
###############################################
echo "[DroidShell] Repo Tools installation complete."
