#!/system/bin/sh
MODDIR=\${0%/*}
# Example: ensure a marker or log
log -t droidshell "DroidShell Magisk module loaded: \$MODDIR"

# DS_ROOT_ADVANCED_HOOKS
MODDIR=\${0%/*}
# Example hook: log and touch a marker
log -t droidshell "DroidShell advanced Magisk service hook active: $MODDIR"
touch "$MODDIR/droidshell.service.active"
