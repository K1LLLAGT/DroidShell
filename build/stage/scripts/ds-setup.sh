#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[DroidShell] Starting setup..."

# ---------- Paths ----------
DS_HOME="$HOME"
DS_CONFIG_DIR="$HOME/.termux"
DS_PLUGIN_DIR="$HOME/.droidshell/plugins"

mkdir -p "$DS_CONFIG_DIR" "$DS_PLUGIN_DIR"

# ---------- Startup Script ----------
echo "[DroidShell] Writing startup script..."
cat > "$DS_HOME/.ds-startup" << 'EOSTART'
echo "=== DroidShell Startup ==="
echo "Initializing environment..."

# Example env
export PATH="$HOME/bin:$PATH"

# Example aliases
alias ll='ls -alF'
alias gs='git status'

echo "DroidShell ready."
EOSTART

chmod +x "$DS_HOME/.ds-startup"

# ---------- Color Scheme ----------
echo "[DroidShell] Writing color scheme..."
cat > "$DS_CONFIG_DIR/colors.properties" << 'EOCOL'
background=#0D0D0D
foreground=#E0E0E0
cursor=#00FF66
selection=#1A3D1A

color0=#000000
color1=#FF5252
color2=#4CAF50
color3=#FFEB3B
color4=#2196F3
color5=#E040FB
color6=#26C6DA
color7=#FAFAFA
color8=#212121
color9=#FF8A80
color10=#69F0AE
color11=#FFFF8D
color12=#82B1FF
color13=#EA80FC
color14=#80DEEA
color15=#FFFFFF
EOCOL

# ---------- termux.properties ----------
echo "[DroidShell] Writing termux.properties..."
cat > "$DS_CONFIG_DIR/termux.properties" << 'EOPROP'
# DroidShell extra keys
extra-keys = [ \
 ['ESC','CTRL','ALT','TAB','HOME','END'], \
 ['UP','DOWN','LEFT','RIGHT','DEL','BKSP'] \
]

# Example: disable bell
bell-character=ignore
EOPROP

# ---------- Plugin Examples (Source Stubs) ----------
echo "[DroidShell] Creating plugin stubs..."

# System Info plugin stub (Java source, not compiled)
cat > "$DS_PLUGIN_DIR/SystemInfoPlugin.java" << 'EOSYS'
public class PluginMain implements DroidShellPlugin {

    @Override
    public String getPluginName() { return "SystemInfo"; }

    @Override
    public String getPluginVersion() { return "1.0"; }

    @Override
    public void onLoad(android.content.Context context) {
        // init if needed
    }

    @Override
    public void onCommand(String cmd, DroidShellPluginCallback cb) {
        if (!"sysinfo".equals(cmd)) {
            cb.onError("Unknown command: " + cmd);
            cb.onComplete();
            return;
        }

        cb.onOutput("Android: " + android.os.Build.VERSION.RELEASE);
        cb.onOutput("Device: " + android.os.Build.MODEL);
        cb.onOutput("ABI: " + android.os.Build.SUPPORTED_ABIS[0]);
        cb.onComplete();
    }
}
EOSYS

# Calculator plugin stub
cat > "$DS_PLUGIN_DIR/CalcPlugin.java" << 'EOCALC'
public class PluginMain implements DroidShellPlugin {

    @Override
    public String getPluginName() { return "Calc"; }

    @Override
    public String getPluginVersion() { return "1.0"; }

    @Override
    public void onLoad(android.content.Context context) { }

    @Override
    public void onCommand(String cmd, DroidShellPluginCallback cb) {
        try {
            javax.script.ScriptEngine engine =
                new javax.script.ScriptEngineManager().getEngineByName("JavaScript");
            Object result = engine.eval(cmd);
            cb.onOutput("Result: " + result);
        } catch (Exception e) {
            cb.onError("Calc error: " + e.getMessage());
        }
        cb.onComplete();
    }
}
EOCALC

# ---------- README ----------
echo "[DroidShell] Writing README..."
cat > "$DS_HOME/DROIDSHHELL_README.txt" << 'EOREAD'
DroidShell Setup Summary
------------------------

Created:
- ~/.ds-startup      : startup script run by DroidShell on launch
- ~/.termux/colors.properties: DroidShell dark color scheme
- ~/.termux/termux.properties: extra keys + basic settings
- ~/.droidshell/plugins/     : plugin source stubs (SystemInfo, Calc)

Next:
- Integrate plugin loader in the DroidShell app (DexClassLoader)
- Point DroidShell to use .ds-startup and this config set
EOREAD

echo "[DroidShell] Setup complete."
