#!/data/data/com.termux/files/usr/bin/bash
set -e

DIR="plugin-template"
mkdir -p "$DIR/src"

echo "[DroidShell] Creating plugin template at $DIR"

# Plugin source
cat > "$DIR/src/PluginMain.java" << 'EOSRC'
import com.droidshell.api.DroidShellPlugin;
import com.droidshell.api.DroidShellPluginCallback;
import android.content.Context;

public class PluginMain implements DroidShellPlugin {

    @Override
    public String getPluginName() { return "MyPlugin"; }

    @Override
    public String getPluginVersion() { return "1.0"; }

    @Override
    public void onLoad(Context context) {
        // Initialization
    }

    @Override
    public void onCommand(String cmd, DroidShellPluginCallback cb) {
        cb.onOutput("MyPlugin received: " + cmd);
        cb.onComplete();
    }
}
EOSRC

# Build script
cat > "$DIR/build.sh" << 'EOBUILD'
#!/bin/bash
set -e
mkdir -p out
javac -d out src/*.java
cd out
jar cf MyPlugin.jar *
echo "Plugin built: out/MyPlugin.jar"
EOBUILD
chmod +x "$DIR/build.sh"

# README
cat > "$DIR/README.md" << 'EOREAD'
# DroidShell Plugin Template

## Build
Run:
    ./build.sh

## Output
Produces:
    out/MyPlugin.jar

## Install
Use:
    droidshell-plugin-deploy.sh out/MyPlugin.jar
EOREAD

echo "[DroidShell] Plugin template created."
