#!/usr/bin/env bash
set -e

SDK_DIR="plugin-sdk"
echo "[DroidShell] Creating Plugin SDK at $SDK_DIR..."

mkdir -p "$SDK_DIR/src"
mkdir -p "$SDK_DIR/examples"
mkdir -p "$SDK_DIR/docs"

# Core interfaces
cat > "$SDK_DIR/src/DroidShellPlugin.java" << 'EOIFACE'
package com.droidshell.api;

import android.content.Context;

public interface DroidShellPlugin {
    String getPluginName();
    String getPluginVersion();
    void onLoad(Context context);
    void onCommand(String command, DroidShellPluginCallback callback);
}
EOIFACE

cat > "$SDK_DIR/src/DroidShellPluginCallback.java" << 'EOCB'
package com.droidshell.api;

public interface DroidShellPluginCallback {
    void onOutput(String text);
    void onError(String error);
    void onComplete();
}
EOCB

# Example plugin
cat > "$SDK_DIR/examples/SystemInfoPlugin.java" << 'EOSYS'
import com.droidshell.api.DroidShellPlugin;
import com.droidshell.api.DroidShellPluginCallback;
import android.content.Context;
import android.os.Build;

public class PluginMain implements DroidShellPlugin {

    @Override
    public String getPluginName() { return "SystemInfo"; }

    @Override
    public String getPluginVersion() { return "1.0"; }

    @Override
    public void onLoad(Context context) { }

    @Override
    public void onCommand(String cmd, DroidShellPluginCallback cb) {
        if (!"sysinfo".equals(cmd)) {
            cb.onError("Unknown command: " + cmd);
            cb.onComplete();
            return;
        }
        cb.onOutput("Android: " + Build.VERSION.RELEASE);
        cb.onOutput("Device: " + Build.MODEL);
        cb.onOutput("ABI: " + Build.SUPPORTED_ABIS[0]);
        cb.onComplete();
    }
}
EOSYS

# SDK README
cat > "$SDK_DIR/docs/README.md" << 'EOREAD'
# DroidShell Plugin SDK

## Overview
DroidShell plugins are loaded dynamically from the app's plugin directory
and must provide a `PluginMain` class implementing `DroidShellPlugin`.

## Interfaces
- DroidShellPlugin
- DroidShellPluginCallback

## Build
Compile your plugin into a JAR or DEX and place it into the DroidShell
plugin directory on device.

## Example
See ../examples/SystemInfoPlugin.java
EOREAD

echo "[DroidShell] Plugin SDK tree created at $SDK_DIR."
