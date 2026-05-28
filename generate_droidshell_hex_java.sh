#!/usr/bin/env bash
set -euo pipefail

# generate_droidshell_hex_java.sh
# Builds a hexagonal, enterprise-grade Java subsystem for:
#   package: com.k1lllagt.droidshell

ROOT="$(pwd)"
APP="$ROOT/app"
SRC="$APP/src/main"
JAVA_ROOT="$SRC/java"
PKG_DIR="$JAVA_ROOT/com/k1lllagt/droidshell"

APP_PKG="$PKG_DIR/app"
DOMAIN_PKG="$PKG_DIR/domain"
DOMAIN_MODEL_PKG="$DOMAIN_PKG/model"
DOMAIN_PORT_PKG="$DOMAIN_PKG/port"
DOMAIN_SERVICE_PKG="$DOMAIN_PKG/service"
APP_LAYER_PKG="$PKG_DIR/application"
INFRA_PKG="$PKG_DIR/infrastructure"
INFRA_SHELL_PKG="$INFRA_PKG/shell"
INFRA_FS_PKG="$INFRA_PKG/filesystem"
INFRA_PLUGIN_PKG="$INFRA_PKG/plugins"
INFRA_WORKSPACE_PKG="$INFRA_PKG/workspace"
UI_PKG="$PKG_DIR/ui"
UI_ACTIVITY_PKG="$UI_PKG/activity"
UI_FRAGMENT_PKG="$UI_PKG/fragment"
UI_ADAPTER_PKG="$UI_PKG/adapter"
UI_THEME_PKG="$UI_PKG/theme"

RES="$SRC/res"
LAYOUT="$RES/layout"
DRAWABLE="$RES/drawable"
RAW="$RES/raw"

echo "=== Creating package structure ==="

mkdir -p \
  "$APP_PKG" \
  "$DOMAIN_MODEL_PKG" \
  "$DOMAIN_PORT_PKG" \
  "$DOMAIN_SERVICE_PKG" \
  "$APP_LAYER_PKG" \
  "$INFRA_SHELL_PKG" \
  "$INFRA_FS_PKG" \
  "$INFRA_PLUGIN_PKG" \
  "$INFRA_WORKSPACE_PKG" \
  "$UI_ACTIVITY_PKG" \
  "$UI_FRAGMENT_PKG" \
  "$UI_ADAPTER_PKG" \
  "$UI_THEME_PKG" \
  "$LAYOUT" \
  "$DRAWABLE" \
  "$RAW"

########################################
# MANIFEST + GRADLE SNIPPETS (MANUAL)
########################################

echo
echo "=== AndroidManifest.xml additions (manual merge) ==="
cat <<'EOF'

<application
    android:name="com.k1lllagt.droidshell.app.DroidShellApp"
    android:allowBackup="true"
    android:theme="@style/Theme.Material3.DayNight.NoActionBar">

    <activity
        android:name="com.k1lllagt.droidshell.ui.activity.MainActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>
    </activity>

    <activity
        android:name="com.k1lllagt.droidshell.ui.activity.DroidShellActivity"
        android:exported="false"/>
</application>

EOF

echo
echo "=== app/build.gradle dependency additions (manual merge) ==="
cat <<'EOF'

dependencies {
    implementation "androidx.core:core-ktx:1.13.1"
    implementation "androidx.appcompat:appcompat:1.7.0"
    implementation "com.google.android.material:material:1.12.0"
    implementation "androidx.recyclerview:recyclerview:1.3.2"
    implementation "androidx.constraintlayout:constraintlayout:2.2.0"
    implementation "androidx.fragment:fragment-ktx:1.8.2"
}

EOF

########################################
# DOMAIN LAYER (pure Java)
########################################

cat > "$DOMAIN_MODEL_PKG/ScriptResult.java" <<'EOF'
package com.k1lllagt.droidshell.domain.model;

public class ScriptResult {
    private final int exitCode;
    private final String stdout;
    private final String stderr;

    public ScriptResult(int exitCode, String stdout, String stderr) {
        this.exitCode = exitCode;
        this.stdout = stdout;
        this.stderr = stderr;
    }

    public int getExitCode() { return exitCode; }
    public String getStdout() { return stdout; }
    public String getStderr() { return stderr; }
}
EOF

cat > "$DOMAIN_MODEL_PKG/PluginDescriptor.java" <<'EOF'
package com.k1lllagt.droidshell.domain.model;

import java.io.File;

public class PluginDescriptor {
    private final String id;
    private final String name;
    private final String version;
    private final String description;
    private final File entryScript;

    public PluginDescriptor(String id, String name, String version, String description, File entryScript) {
        this.id = id;
        this.name = name;
        this.version = version;
        this.description = description;
        this.entryScript = entryScript;
    }

    public String getId() { return id; }
    public String getName() { return name; }
    public String getVersion() { return version; }
    public String getDescription() { return description; }
    public File getEntryScript() { return entryScript; }
}
EOF

cat > "$DOMAIN_PORT_PKG/ShellExecutor.java" <<'EOF'
package com.k1lllagt.droidshell.domain.port;

import com.k1lllagt.droidshell.domain.model.ScriptResult;
import java.io.File;
import java.util.List;

public interface ShellExecutor {
    ScriptResult execute(List<String> command, File workingDir);
}
EOF

cat > "$DOMAIN_PORT_PKG/WorkspacePort.java" <<'EOF'
package com.k1lllagt.droidshell.domain.port;

import java.io.File;

public interface WorkspacePort {
    File getInternalRoot();
    File getPublicRoot();
    File resolveFolder(String name);
}
EOF

cat > "$DOMAIN_PORT_PKG/PluginRepositoryPort.java" <<'EOF'
package com.k1lllagt.droidshell.domain.port;

import com.k1lllagt.droidshell.domain.model.PluginDescriptor;
import java.util.List;

public interface PluginRepositoryPort {
    List<PluginDescriptor> listPlugins();
}
EOF

cat > "$DOMAIN_SERVICE_PKG/ScriptService.java" <<'EOF'
package com.k1lllagt.droidshell.domain.service;

import com.k1lllagt.droidshell.domain.model.ScriptResult;
import com.k1lllagt.droidshell.domain.port.ShellExecutor;
import com.k1lllagt.droidshell.domain.port.WorkspacePort;

import java.io.File;
import java.util.Arrays;

public class ScriptService {

    private final ShellExecutor shellExecutor;
    private final WorkspacePort workspacePort;

    public ScriptService(ShellExecutor shellExecutor, WorkspacePort workspacePort) {
        this.shellExecutor = shellExecutor;
        this.workspacePort = workspacePort;
    }

    public ScriptResult runScript(String relativePath) {
        File internal = new File(workspacePort.getInternalRoot(), "scripts/" + relativePath);
        File external = new File(workspacePort.getPublicRoot(), "scripts/" + relativePath);
        File script = internal.exists() ? internal : external;
        return shellExecutor.execute(Arrays.asList(script.getAbsolutePath()), script.getParentFile());
    }
}
EOF

cat > "$DOMAIN_SERVICE_PKG/PluginService.java" <<'EOF'
package com.k1lllagt.droidshell.domain.service;

import com.k1lllagt.droidshell.domain.model.PluginDescriptor;
import com.k1lllagt.droidshell.domain.model.ScriptResult;
import com.k1lllagt.droidshell.domain.port.PluginRepositoryPort;
import com.k1lllagt.droidshell.domain.port.ShellExecutor;

import java.io.File;
import java.util.List;
import java.util.Arrays;

public class PluginService {

    private final PluginRepositoryPort pluginRepository;
    private final ShellExecutor shellExecutor;

    public PluginService(PluginRepositoryPort pluginRepository, ShellExecutor shellExecutor) {
        this.pluginRepository = pluginRepository;
        this.shellExecutor = shellExecutor;
    }

    public List<PluginDescriptor> listPlugins() {
        return pluginRepository.listPlugins();
    }

    public ScriptResult runPlugin(PluginDescriptor plugin) {
        File script = plugin.getEntryScript();
        return shellExecutor.execute(Arrays.asList(script.getAbsolutePath()), script.getParentFile());
    }
}
EOF

########################################
# APPLICATION LAYER (use cases)
########################################

cat > "$APP_LAYER_PKG/DroidShellUseCases.java" <<'EOF'
package com.k1lllagt.droidshell.application;

import com.k1lllagt.droidshell.domain.model.PluginDescriptor;
import com.k1lllagt.droidshell.domain.model.ScriptResult;
import com.k1lllagt.droidshell.domain.service.PluginService;
import com.k1lllagt.droidshell.domain.service.ScriptService;

import java.util.List;

public class DroidShellUseCases {

    private final ScriptService scriptService;
    private final PluginService pluginService;

    public DroidShellUseCases(ScriptService scriptService, PluginService pluginService) {
        this.scriptService = scriptService;
        this.pluginService = pluginService;
    }

    public ScriptResult runScript(String relativePath) {
        return scriptService.runScript(relativePath);
    }

    public List<PluginDescriptor> listPlugins() {
        return pluginService.listPlugins();
    }

    public ScriptResult runPlugin(PluginDescriptor plugin) {
        return pluginService.runPlugin(plugin);
    }
}
EOF

########################################
# INFRASTRUCTURE: SHELL, WORKSPACE, PLUGINS
########################################

cat > "$INFRA_SHELL_PKG/ProcessShellExecutor.java" <<'EOF'
package com.k1lllagt.droidshell.infrastructure.shell;

import com.k1lllagt.droidshell.domain.model.ScriptResult;
import com.k1lllagt.droidshell.domain.port.ShellExecutor;

import android.util.Log;

import java.io.*;
import java.util.List;

public class ProcessShellExecutor implements ShellExecutor {

    private static final String TAG = "ProcessShellExecutor";

    @Override
    public ScriptResult execute(List<String> command, File workingDir) {
        try {
            ProcessBuilder pb = new ProcessBuilder(command);
            if (workingDir != null) {
                pb.directory(workingDir);
            }
            pb.redirectErrorStream(false);
            Process p = pb.start();

            String stdout = readStream(p.getInputStream());
            String stderr = readStream(p.getErrorStream());
            int code = p.waitFor();

            return new ScriptResult(code, stdout, stderr);
        } catch (Exception e) {
            Log.e(TAG, "Execution failed", e);
            return new ScriptResult(-1, "", e.getMessage() != null ? e.getMessage() : "error");
        }
    }

    private String readStream(InputStream is) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(is));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            sb.append(line).append('\n');
        }
        return sb.toString();
    }
}
EOF

cat > "$INFRA_WORKSPACE_PKG/AndroidWorkspaceAdapter.java" <<'EOF'
package com.k1lllagt.droidshell.infrastructure.workspace;

import android.content.Context;

import com.k1lllagt.droidshell.domain.port.WorkspacePort;

import java.io.File;

public class AndroidWorkspaceAdapter implements WorkspacePort {

    private final Context context;

    public AndroidWorkspaceAdapter(Context context) {
        this.context = context.getApplicationContext();
    }

    @Override
    public File getInternalRoot() {
        File base = context.getExternalFilesDir(null);
        File root = new File(base, "DroidShell");
        root.mkdirs();
        return root;
    }

    @Override
    public File getPublicRoot() {
        File root = new File("/sdcard/DroidShell");
        root.mkdirs();
        return root;
    }

    @Override
    public File resolveFolder(String name) {
        File internal = new File(getInternalRoot(), name);
        File external = new File(getPublicRoot(), name);
        if (internal.exists()) return internal;
        if (external.exists()) return external;
        return internal;
    }
}
EOF

cat > "$INFRA_PLUGIN_PKG/JsonPluginRepository.java" <<'EOF'
package com.k1lllagt.droidshell.infrastructure.plugins;

import com.k1lllagt.droidshell.domain.model.PluginDescriptor;
import com.k1lllagt.droidshell.domain.port.PluginRepositoryPort;
import com.k1lllagt.droidshell.domain.port.WorkspacePort;

import org.json.JSONObject;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class JsonPluginRepository implements PluginRepositoryPort {

    private final WorkspacePort workspacePort;

    public JsonPluginRepository(WorkspacePort workspacePort) {
        this.workspacePort = workspacePort;
    }

    @Override
    public List<PluginDescriptor> listPlugins() {
        List<PluginDescriptor> result = new ArrayList<>();
        File internal = new File(workspacePort.getInternalRoot(), "plugins");
        File external = new File(workspacePort.getPublicRoot(), "plugins");

        scanDir(internal, result);
        scanDir(external, result);

        return result;
    }

    private void scanDir(File root, List<PluginDescriptor> out) {
        if (!root.exists() || !root.isDirectory()) return;
        File[] dirs = root.listFiles(File::isDirectory);
        if (dirs == null) return;
        for (File dir : dirs) {
            PluginDescriptor d = loadPlugin(dir);
            if (d != null) out.add(d);
        }
    }

    private PluginDescriptor loadPlugin(File dir) {
        File manifest = new File(dir, "manifest.json");
        if (!manifest.exists()) return null;
        try {
            String json = readAll(manifest);
            JSONObject o = new JSONObject(json);
            String id = o.optString("id", dir.getName());
            String name = o.optString("name", dir.getName());
            String version = o.optString("version", "0.0.0");
            String desc = o.optString("description", null);
            String entryName = o.optString("entry", "plugin.sh");
            File entry = new File(dir, entryName);
            if (!entry.exists()) return null;
            return new PluginDescriptor(id, name, version, desc, entry);
        } catch (Exception e) {
            return null;
        }
    }

    private String readAll(File f) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(f));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            sb.append(line).append('\n');
        }
        return sb.toString();
    }
}
EOF

########################################
# APP LAYER: Application + DI wiring
########################################

cat > "$APP_PKG/DroidShellApp.java" <<'EOF'
package com.k1lllagt.droidshell.app;

import android.app.Application;

import com.k1lllagt.droidshell.application.DroidShellUseCases;
import com.k1lllagt.droidshell.domain.port.PluginRepositoryPort;
import com.k1lllagt.droidshell.domain.port.ShellExecutor;
import com.k1lllagt.droidshell.domain.port.WorkspacePort;
import com.k1lllagt.droidshell.domain.service.PluginService;
import com.k1lllagt.droidshell.domain.service.ScriptService;
import com.k1lllagt.droidshell.infrastructure.plugins.JsonPluginRepository;
import com.k1lllagt.droidshell.infrastructure.shell.ProcessShellExecutor;
import com.k1lllagt.droidshell.infrastructure.workspace.AndroidWorkspaceAdapter;

public class DroidShellApp extends Application {

    private DroidShellUseCases useCases;

    @Override
    public void onCreate() {
        super.onCreate();
        init();
        bootstrapWorkspace();
    }

    private void init() {
        WorkspacePort workspacePort = new AndroidWorkspaceAdapter(this);
        ShellExecutor shellExecutor = new ProcessShellExecutor();
        PluginRepositoryPort pluginRepo = new JsonPluginRepository(workspacePort);

        ScriptService scriptService = new ScriptService(shellExecutor, workspacePort);
        PluginService pluginService = new PluginService(pluginRepo, shellExecutor);

        useCases = new DroidShellUseCases(scriptService, pluginService);
    }

    private void bootstrapWorkspace() {
        WorkspacePort workspacePort = new AndroidWorkspaceAdapter(this);
        String[] dirs = new String[] {
                "bin","plugins","themes","scripts","workspace","packages","config","logs"
        };
        for (String d : dirs) {
            workspacePort.resolveFolder(d).mkdirs();
        }
    }

    public DroidShellUseCases getUseCases() {
        return useCases;
    }

    public static DroidShellUseCases from(android.content.Context ctx) {
        return ((DroidShellApp) ctx.getApplicationContext()).getUseCases();
    }
}
EOF

########################################
# UI THEME + ICONS
########################################

cat > "$UI_THEME_PKG/ThemeManager.java" <<'EOF'
package com.k1lllagt.droidshell.ui.theme;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Color;

import org.json.JSONObject;

public class ThemeManager {

    public static class Theme {
        public final int accent;
        public final int background;
        public final int title;
        public final int tint;

        public Theme(int accent, int background, int title, int tint) {
            this.accent = accent;
            this.background = background;
            this.title = title;
            this.tint = tint;
        }
    }

    private static Theme cache;

    public static Theme get(Context context) {
        if (cache != null) return cache;
        Resources res = context.getResources();
        String pkg = context.getPackageName();
        int id = res.getIdentifier("droidshell_theme", "raw", pkg);
        if (id != 0) {
            try {
                String json = new java.io.BufferedReader(
                        new java.io.InputStreamReader(res.openRawResource(id))
                ).lines().reduce("", (a,b)->a + b);
                JSONObject o = new JSONObject(json);
                cache = new Theme(
                        Color.parseColor(o.optString("accent", "#00FF7F")),
                        Color.parseColor(o.optString("background", "#101010")),
                        Color.parseColor(o.optString("title", "#FFFFFF")),
                        Color.parseColor(o.optString("tint", "#00FF7F"))
                );
                return cache;
            } catch (Exception ignored) {}
        }
        cache = new Theme(Color.GREEN, Color.BLACK, Color.WHITE, Color.GREEN);
        return cache;
    }
}
EOF

cat > "$UI_THEME_PKG/IconResolver.java" <<'EOF'
package com.k1lllagt.droidshell.ui.theme;

import android.content.Context;
import android.content.res.Resources;

import com.k1lllagt.droidshell.R;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class IconResolver {

    private static Map<String,Integer> map;

    private static void ensure(Context context) {
        if (map != null) return;
        map = new HashMap<>();
        Resources res = context.getResources();
        String pkg = context.getPackageName();
        int id = res.getIdentifier("droidshell_icon_map", "raw", pkg);
        if (id != 0) {
            try {
                String json = new java.io.BufferedReader(
                        new java.io.InputStreamReader(res.openRawResource(id))
                ).lines().reduce("", (a,b)->a + b);
                JSONObject o = new JSONObject(json);
                Iterator<String> it = o.keys();
                while (it.hasNext()) {
                    String key = it.next();
                    String drawableName = o.getString(key);
                    int d = res.getIdentifier(drawableName, "drawable", pkg);
                    if (d != 0) {
                        map.put(key.toLowerCase(), d);
                    }
                }
            } catch (Exception ignored) {}
        }

        putIfAbsent("bin", R.drawable.ic_droidshell_bin);
        putIfAbsent("plugins", R.drawable.ic_droidshell_plugins);
        putIfAbsent("themes", R.drawable.ic_droidshell_themes);
        putIfAbsent("scripts", R.drawable.ic_droidshell_scripts);
        putIfAbsent("workspace", R.drawable.ic_droidshell_workspace);
        putIfAbsent("packages", R.drawable.ic_droidshell_packages);
        putIfAbsent("config", R.drawable.ic_droidshell_config);
        putIfAbsent("logs", R.drawable.ic_droidshell_logs);
    }

    private static void putIfAbsent(String key, int value) {
        if (!map.containsKey(key.toLowerCase())) {
            map.put(key.toLowerCase(), value);
        }
    }

    public static int folder(Context context, String name) {
        ensure(context);
        Integer d = map.get(name.toLowerCase());
        return d != null ? d : R.drawable.ic_folder_default;
    }
}
EOF

########################################
# UI: ACTIVITIES
########################################

cat > "$UI_ACTIVITY_PKG/MainActivity.java" <<'EOF'
package com.k1lllagt.droidshell.ui.activity;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.k1lllagt.droidshell.R;
import com.k1lllagt.droidshell.ui.fragment.FolderListFragment;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.mainContainer, new FolderListFragment())
                    .commit();
        }
    }
}
EOF

cat > "$UI_ACTIVITY_PKG/DroidShellActivity.java" <<'EOF'
package com.k1lllagt.droidshell.ui.activity;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.k1lllagt.droidshell.R;
import com.k1lllagt.droidshell.ui.fragment.FolderListFragment;

public class DroidShellActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.mainContainer, new FolderListFragment())
                    .commit();
        }
    }
}
EOF

########################################
# UI: ADAPTERS
########################################

cat > "$UI_ADAPTER_PKG/FolderListAdapter.java" <<'EOF'
package com.k1lllagt.droidshell.ui.adapter;

import android.content.Context;
import android.content.res.ColorStateList;
import android.view.*;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.core.widget.ImageViewCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.k1lllagt.droidshell.R;
import com.k1lllagt.droidshell.ui.theme.IconResolver;
import com.k1lllagt.droidshell.ui.theme.ThemeManager;

import java.util.List;

public class FolderListAdapter extends RecyclerView.Adapter<FolderListAdapter.ViewHolder> {

    public interface OnFolderClickListener {
        void onFolderClick(String name);
    }

    private final Context context;
    private final List<String> items;
    private final OnFolderClickListener listener;
    private final ThemeManager.Theme theme;

    public FolderListAdapter(Context context, List<String> items, OnFolderClickListener listener) {
        this.context = context;
        this.items = items;
        this.listener = listener;
        this.theme = ThemeManager.get(context);
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView icon;
        TextView title;
        public ViewHolder(View v) {
            super(v);
            icon = v.findViewById(R.id.folderIcon);
            title = v.findViewById(R.id.folderTitle);
        }
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_folder, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(ViewHolder h, int position) {
        final String name = items.get(position);
        h.title.setText(name);
        h.title.setTextColor(theme.title);
        h.icon.setImageResource(IconResolver.folder(context, name));
        ImageViewCompat.setImageTintList(h.icon, ColorStateList.valueOf(theme.tint));
        h.itemView.setOnClickListener(v -> listener.onFolderClick(name));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }
}
EOF

cat > "$UI_ADAPTER_PKG/PluginListAdapter.java" <<'EOF'
package com.k1lllagt.droidshell.ui.adapter;

import android.view.*;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.k1lllagt.droidshell.R;
import com.k1lllagt.droidshell.domain.model.PluginDescriptor;

import java.util.List;

public class PluginListAdapter extends RecyclerView.Adapter<PluginListAdapter.ViewHolder> {

    public interface OnPluginClickListener {
        void onPluginClick(PluginDescriptor plugin);
    }

    private final List<PluginDescriptor> items;
    private final OnPluginClickListener listener;

    public PluginListAdapter(List<PluginDescriptor> items, OnPluginClickListener listener) {
        this.items = items;
        this.listener = listener;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView name;
        TextView version;
        TextView desc;
        public ViewHolder(View v) {
            super(v);
            name = v.findViewById(R.id.pluginName);
            version = v.findViewById(R.id.pluginVersion);
            desc = v.findViewById(R.id.pluginDescription);
        }
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_plugin, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(ViewHolder h, int position) {
        final PluginDescriptor p = items.get(position);
        h.name.setText(p.getName());
        h.version.setText(p.getVersion());
        h.desc.setText(p.getDescription() != null ? p.getDescription() : p.getId());
        h.itemView.setOnClickListener(v -> listener.onPluginClick(p));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }
}
EOF

########################################
# UI: FRAGMENTS
########################################

cat > "$UI_FRAGMENT_PKG/FolderListFragment.java" <<'EOF'
package com.k1lllagt.droidshell.ui.fragment;

import android.os.Bundle;
import android.view.*;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.k1lllagt.droidshell.R;
import com.k1lllagt.droidshell.ui.adapter.FolderListAdapter;

import java.util.Arrays;
import java.util.List;

public class FolderListFragment extends Fragment {

    private static final List<String> FOLDERS = Arrays.asList(
            "bin","plugins","themes","scripts","workspace","packages","config","logs"
    );

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.fragment_folder_list, container, false);
        RecyclerView rv = v.findViewById(R.id.folderRecyclerView);
        rv.setLayoutManager(new LinearLayoutManager(requireContext()));
        rv.setAdapter(new FolderListAdapter(requireContext(), FOLDERS, name -> {
            getParentFragmentManager().beginTransaction()
                    .replace(R.id.mainContainer, FolderDetailFragment.newInstance(name))
                    .addToBackStack(null)
                    .commit();
        }));
        return v;
    }
}
EOF

cat > "$UI_FRAGMENT_PKG/FolderDetailFragment.java" <<'EOF'
package com.k1lllagt.droidshell.ui.fragment;

import android.os.Bundle;
import android.view.*;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.k1lllagt.droidshell.R;
import com.k1lllagt.droidshell.app.DroidShellApp;
import com.k1lllagt.droidshell.domain.port.WorkspacePort;
import com.k1lllagt.droidshell.infrastructure.workspace.AndroidWorkspaceAdapter;

import java.io.File;
import java.util.Arrays;
import java.util.Comparator;

public class FolderDetailFragment extends Fragment {

    private static final String ARG_FOLDER = "folder";

    public static FolderDetailFragment newInstance(String folder) {
        FolderDetailFragment f = new FolderDetailFragment();
        Bundle b = new Bundle();
        b.putString(ARG_FOLDER, folder);
        f.setArguments(b);
        return f;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.fragment_folder_detail, container, false);
        RecyclerView rv = v.findViewById(R.id.fileRecyclerView);
        rv.setLayoutManager(new LinearLayoutManager(requireContext()));

        String folder = getArguments() != null ? getArguments().getString(ARG_FOLDER, "") : "";
        WorkspacePort workspace = new AndroidWorkspaceAdapter(requireContext());
        File root = workspace.resolveFolder(folder);
        File[] files = root.listFiles();
        if (files == null) files = new File[0];
        Arrays.sort(files, Comparator.comparing(File::isFile).thenComparing(File::getName, String.CASE_INSENSITIVE_ORDER));

        rv.setAdapter(new FileListAdapter(files, file -> {
            if (file.isDirectory()) {
                getParentFragmentManager().beginTransaction()
                        .replace(R.id.mainContainer, newInstance(file.getName()))
                        .addToBackStack(null)
                        .commit();
            } else if (file.getName().endsWith(".sh")) {
                com.k1lllagt.droidshell.application.DroidShellUseCases useCases =
                        DroidShellApp.from(requireContext());
                com.k1lllagt.droidshell.domain.model.ScriptResult r =
                        useCases.runScript(folder + "/" + file.getName());
                getParentFragmentManager().beginTransaction()
                        .replace(R.id.mainContainer,
                                ScriptOutputFragment.newInstance(
                                        "Script: " + file.getName(),
                                        r.getStdout(),
                                        r.getStderr(),
                                        r.getExitCode()))
                        .addToBackStack(null)
                        .commit();
            }
        }));

        return v;
    }
}
EOF

cat > "$UI_FRAGMENT_PKG/FileListAdapter.java" <<'EOF'
package com.k1lllagt.droidshell.ui.fragment;

import android.view.*;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.k1lllagt.droidshell.R;

import java.io.File;

public class FileListAdapter extends RecyclerView.Adapter<FileListAdapter.ViewHolder> {

    public interface OnFileClickListener {
        void onFileClick(File file);
    }

    private final File[] files;
    private final OnFileClickListener listener;

    public FileListAdapter(File[] files, OnFileClickListener listener) {
        this.files = files;
        this.listener = listener;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView icon;
        TextView name;
        TextView meta;
        public ViewHolder(View v) {
            super(v);
            icon = v.findViewById(R.id.fileIcon);
            name = v.findViewById(R.id.fileName);
            meta = v.findViewById(R.id.fileMeta);
        }
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_file, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(ViewHolder h, int position) {
        final File f = files[position];
        h.name.setText(f.getName());
        if (f.isDirectory()) {
            h.meta.setText("Directory");
            h.icon.setImageResource(R.drawable.ic_folder_default);
        } else {
            h.meta.setText(f.length() + " bytes");
            h.icon.setImageResource(R.drawable.ic_droidshell_scripts);
        }
        h.itemView.setOnClickListener(v -> listener.onFileClick(f));
    }

    @Override
    public int getItemCount() {
        return files.length;
    }
}
EOF

cat > "$UI_FRAGMENT_PKG/ScriptOutputFragment.java" <<'EOF'
package com.k1lllagt.droidshell.ui.fragment;

import android.os.Bundle;
import android.view.*;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.k1lllagt.droidshell.R;

public class ScriptOutputFragment extends Fragment {

    private static final String ARG_TITLE = "t";
    private static final String ARG_STDOUT = "o";
    private static final String ARG_STDERR = "e";
    private static final String ARG_EXIT = "c";

    public static ScriptOutputFragment newInstance(String title, String stdout, String stderr, int exitCode) {
        ScriptOutputFragment f = new ScriptOutputFragment();
        Bundle b = new Bundle();
        b.putString(ARG_TITLE, title);
        b.putString(ARG_STDOUT, stdout);
        b.putString(ARG_STDERR, stderr);
        b.putInt(ARG_EXIT, exitCode);
        f.setArguments(b);
        return f;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.fragment_script_output, container, false);
        Bundle args = getArguments() != null ? getArguments() : new Bundle();
        ((TextView) v.findViewById(R.id.scriptTitle)).setText(args.getString(ARG_TITLE, "Script Output"));
        ((TextView) v.findViewById(R.id.scriptStdout)).setText(args.getString(ARG_STDOUT, ""));
        ((TextView) v.findViewById(R.id.scriptStderr)).setText(args.getString(ARG_STDERR, ""));
        ((TextView) v.findViewById(R.id.scriptExitCode)).setText("Exit code: " + args.getInt(ARG_EXIT, -1));
        return v;
    }
}
EOF

########################################
# LAYOUTS
########################################

cat > "$LAYOUT/activity_main.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/mainContainer"
    android:layout_width="match_parent"
    android:layout_height="match_parent"/>
EOF

cat > "$LAYOUT/fragment_folder_list.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/folderRecyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="4dp"/>
</androidx.coordinatorlayout.widget.CoordinatorLayout>
EOF

cat > "$LAYOUT/fragment_folder_detail.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/fileRecyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="4dp"/>
</androidx.coordinatorlayout.widget.CoordinatorLayout>
EOF

cat > "$LAYOUT/item_folder.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="horizontal"
    android:padding="8dp"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:foreground="?attr/selectableItemBackground">

    <ImageView
        android:id="@+id/folderIcon"
        android:layout_width="32dp"
        android:layout_height="32dp"
        android:layout_marginEnd="8dp"/>

    <TextView
        android:id="@+id/folderTitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textStyle="bold"/>
</LinearLayout>
EOF

cat > "$LAYOUT/item_file.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="horizontal"
    android:padding="8dp"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:foreground="?attr/selectableItemBackground">

    <ImageView
        android:id="@+id/fileIcon"
        android:layout_width="32dp"
        android:layout_height="32dp"
        android:layout_marginEnd="8dp"/>

    <LinearLayout
        android:orientation="vertical"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1">

        <TextView
            android:id="@+id/fileName"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textStyle="bold"/>

        <TextView
            android:id="@+id/fileMeta"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="12sp"/>
    </LinearLayout>
</LinearLayout>
EOF

cat > "$LAYOUT/fragment_script_output.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="12dp">

    <LinearLayout
        android:orientation="vertical"
        android:layout_width="match_parent"
        android:layout_height="wrap_content">

        <TextView
            android:id="@+id/scriptTitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textStyle="bold"
            android:textSize="18sp"
            android:paddingBottom="8dp"/>

        <TextView
            android:id="@+id/scriptExitCode"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="14sp"
            android:paddingBottom="8dp"/>

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="STDOUT:"
            android:textStyle="bold"/>

        <TextView
            android:id="@+id/scriptStdout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:paddingBottom="12dp"
            android:textIsSelectable="true"/>

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="STDERR:"
            android:textStyle="bold"/>

        <TextView
            android:id="@+id/scriptStderr"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textIsSelectable="true"/>

    </LinearLayout>
</ScrollView>
EOF

cat > "$LAYOUT/fragment_plugin_list.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/pluginRecyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="4dp"/>
</androidx.coordinatorlayout.widget.CoordinatorLayout>
EOF

cat > "$LAYOUT/item_plugin.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.cardview.widget.CardView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_margin="8dp"
    android:foreground="?attr/selectableItemBackground">

    <LinearLayout
        android:orientation="vertical"
        android:padding="12dp"
        android:layout_width="match_parent"
        android:layout_height="wrap_content">

        <TextView
            android:id="@+id/pluginName"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textStyle="bold"
            android:textSize="16sp"/>

        <TextView
            android:id="@+id/pluginVersion"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="12sp"
            android:paddingTop="2dp"/>

        <TextView
            android:id="@+id/pluginDescription"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:paddingTop="4dp"
            android:textSize="14sp"/>

    </LinearLayout>
</androidx.cardview.widget.CardView>
EOF

########################################
# RAW CONFIGS
########################################

cat > "$RAW/droidshell_theme.json" <<'EOF'
{
  "accent": "#00FF7F",
  "background": "#101010",
  "title": "#FFFFFF",
  "tint": "#00FF7F"
}
EOF

cat > "$RAW/droidshell_icon_map.json" <<'EOF'
{
  "bin": "ic_droidshell_bin",
  "plugins": "ic_droidshell_plugins",
  "themes": "ic_droidshell_themes",
  "scripts": "ic_droidshell_scripts",
  "workspace": "ic_droidshell_workspace",
  "packages": "ic_droidshell_packages",
  "config": "ic_droidshell_config",
  "logs": "ic_droidshell_logs"
}
EOF

echo
echo "=== NOTE: create placeholder drawables in res/drawable/ ==="
echo "ic_droidshell_bin.xml, ic_droidshell_plugins.xml, ic_droidshell_themes.xml, ic_droidshell_scripts.xml,"
echo "ic_droidshell_workspace.xml, ic_droidshell_packages.xml, ic_droidshell_config.xml, ic_droidshell_logs.xml,"
echo "ic_folder_default.xml"
echo
echo "DroidShell hexagonal Java subsystem generated."
