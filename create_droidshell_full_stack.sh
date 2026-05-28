#!/usr/bin/env bash
set -euo pipefail

PKG_DIR="app/src/main/java/com/k1lllagt/droidshell"
RES_DIR="app/src/main/res"
DRAWABLE_DIR="$RES_DIR/drawable"
LAYOUT_DIR="$RES_DIR/layout"
RAW_DIR="$RES_DIR/raw"
SCRIPTS_DIR="tools"
ASSETS_SVG_DIR="assets/droidshell_icons/svg"

mkdir -p "$PKG_DIR" "$DRAWABLE_DIR" "$LAYOUT_DIR" "$RAW_DIR" "$SCRIPTS_DIR" "$ASSETS_SVG_DIR"

# --- Minimal placeholder SVGs (you’ll replace with real ones) ---
cat > "$ASSETS_SVG_DIR/ds_bin.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <rect x="2" y="4" width="20" height="16" rx="2" fill="#071E1A"/>
  <rect x="6" y="8" width="12" height="8" fill="#00FF7F"/>
</svg>
SVG

# (You can add more ds_*.svg here as needed)

# --- Basic vector placeholders (you’ll overwrite via Vector Asset import) ---
cat > "$DRAWABLE_DIR/ic_droidshell_bin.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#071E1A" android:pathData="M2,4h20v16H2z"/>
  <path android:fillColor="#00FF7F" android:pathData="M6,8h12v8H6z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_folder_default.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#90A4AE" android:pathData="M3,6h6l2,2h10v10H3z"/>
</vector>
XML

# Add simple placeholders for other icons used by IconResolver:
cat > "$DRAWABLE_DIR/ic_droidshell_plugins.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#0AB4FF" android:pathData="M4,10h16v10H4z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_themes.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFB86B" android:pathData="M12,2a10,10 0 1 0 0,20a10,10 0 0 0 0,-20z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_scripts.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#0B3F00" android:pathData="M3,3h18v18H3z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_workspace.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFD700" android:pathData="M2,6h20v12H2z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_packages.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#C0C0C0" android:pathData="M3,7l9,-4 9,4v10l-9,4-9,-4z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_config.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FF6B6B" android:pathData="M4,8h16v12H4z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_logs.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFFFFF" android:pathData="M4,4h16v16H4z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_folder_download.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#2196F3" android:pathData="M5,20h14v-2H5z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_folder_documents.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#4CAF50" android:pathData="M6,2h9l5,5v13H6z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_folder_photos.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FF7043" android:pathData="M4,6h16v12H4z"/>
</vector>
XML

# --- JSON mapping for icons + theme ---
cat > "$RAW_DIR/droidshell_icon_map.json" <<'JSON'
{
  "bin": "ic_droidshell_bin",
  "binaries": "ic_droidshell_bin",
  "plugins": "ic_droidshell_plugins",
  "extensions": "ic_droidshell_plugins",
  "themes": "ic_droidshell_themes",
  "scripts": "ic_droidshell_scripts",
  "workspace": "ic_droidshell_workspace",
  "packages": "ic_droidshell_packages",
  "config": "ic_droidshell_config",
  "logs": "ic_droidshell_logs",
  "downloads": "ic_folder_download",
  "documents": "ic_folder_documents",
  "dcim": "ic_folder_photos"
}
JSON

cat > "$RAW_DIR/droidshell_theme.json" <<'JSON'
{
  "accentColor": "#00FF7F",
  "backgroundColor": "#101010",
  "folderTitleColor": "#FFFFFF",
  "iconTint": "#00FF7F"
}
JSON

# --- Layouts ---
cat > "$LAYOUT_DIR/item_folder.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="72dp"
    android:layout_margin="8dp"
    app:cardCornerRadius="12dp"
    app:cardUseCompatPadding="true">

    <androidx.constraintlayout.widget.ConstraintLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="12dp">

        <ImageView
            android:id="@+id/folderIcon"
            android:layout_width="40dp"
            android:layout_height="40dp"
            android:contentDescription="@string/folder_icon"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintBottom_toBottomOf="parent" />

        <TextView
            android:id="@+id/folderTitle"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:text="Folder"
            android:textAppearance="@style/TextAppearance.Material3.BodyLarge"
            app:layout_constraintStart_toEndOf="@id/folderIcon"
            app:layout_constraintTop_toTopOf="@id/folderIcon"
            app:layout_constraintBottom_toBottomOf="@id/folderIcon"
            app:layout_constraintEnd_toEndOf="parent"
            android:paddingStart="12dp"/>

    </androidx.constraintlayout.widget.ConstraintLayout>
</com.google.android.material.card.MaterialCardView>
XML

cat > "$LAYOUT_DIR/fragment_folder_list.xml" <<'XML'
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
XML

# --- Kotlin: Theme engine, IconResolver, Adapter, Fragment, App class ---
cat > "$PKG_DIR/ThemeManager.kt" <<'KT'
package com.k1lllagt.droidshell

import android.content.Context
import android.graphics.Color
import androidx.annotation.ColorInt
import org.json.JSONObject

data class DroidShellTheme(
    @ColorInt val accentColor: Int,
    @ColorInt val backgroundColor: Int,
    @ColorInt val folderTitleColor: Int,
    @ColorInt val iconTint: Int
)

object ThemeManager {

    private var cachedTheme: DroidShellTheme? = null

    fun getTheme(context: Context): DroidShellTheme {
        cachedTheme?.let { return it }

        val res = context.resources
        val rawId = res.getIdentifier("droidshell_theme", "raw", context.packageName)
        val theme = if (rawId != 0) {
            val json = res.openRawResource(rawId).bufferedReader().use { it.readText() }
            val obj = JSONObject(json)
            DroidShellTheme(
                accentColor = Color.parseColor(obj.optString("accentColor", "#00FF7F")),
                backgroundColor = Color.parseColor(obj.optString("backgroundColor", "#101010")),
                folderTitleColor = Color.parseColor(obj.optString("folderTitleColor", "#FFFFFF")),
                iconTint = Color.parseColor(obj.optString("iconTint", "#00FF7F"))
            )
        } else {
            DroidShellTheme(
                accentColor = Color.parseColor("#00FF7F"),
                backgroundColor = Color.parseColor("#101010"),
                folderTitleColor = Color.WHITE,
                iconTint = Color.parseColor("#00FF7F")
            )
        }

        cachedTheme = theme
        return theme
    }
}
KT

cat > "$PKG_DIR/IconResolver.kt" <<'KT'
package com.k1lllagt.droidshell

import android.content.Context
import androidx.annotation.DrawableRes
import org.json.JSONObject

object IconResolver {

    private var nameToRes: Map<String, Int>? = null

    private fun ensureLoaded(context: Context) {
        if (nameToRes != null) return

        val res = context.resources
        val pkg = context.packageName
        val map = mutableMapOf<String, Int>()

        val rawId = res.getIdentifier("droidshell_icon_map", "raw", pkg)
        if (rawId != 0) {
            val json = res.openRawResource(rawId).bufferedReader().use { it.readText() }
            val obj = JSONObject(json)
            obj.keys().forEach { key ->
                val drawableName = obj.getString(key)
                val drawableId = res.getIdentifier(drawableName, "drawable", pkg)
                if (drawableId != 0) map[key.lowercase()] = drawableId
            }
        }

        fun fallback(name: String, @DrawableRes id: Int) {
            map.putIfAbsent(name.lowercase(), id)
        }

        fallback("bin", R.drawable.ic_droidshell_bin)
        fallback("plugins", R.drawable.ic_droidshell_plugins)
        fallback("themes", R.drawable.ic_droidshell_themes)
        fallback("scripts", R.drawable.ic_droidshell_scripts)
        fallback("workspace", R.drawable.ic_droidshell_workspace)
        fallback("packages", R.drawable.ic_droidshell_packages)
        fallback("config", R.drawable.ic_droidshell_config)
        fallback("logs", R.drawable.ic_droidshell_logs)
        fallback("downloads", R.drawable.ic_folder_download)
        fallback("documents", R.drawable.ic_folder_documents)
        fallback("dcim", R.drawable.ic_folder_photos)

        nameToRes = map
    }

    @DrawableRes
    fun resolveFolderIcon(context: Context, folderName: String?): Int {
        if (folderName.isNullOrBlank()) return R.drawable.ic_folder_default
        ensureLoaded(context)
        return nameToRes?.get(folderName.trim().lowercase()) ?: R.drawable.ic_folder_default
    }
}
KT

cat > "$PKG_DIR/FileManagerAdapter.kt" <<'KT'
package com.k1lllagt.droidshell

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.core.widget.ImageViewCompat
import androidx.recyclerview.widget.RecyclerView

class FileManagerAdapter(
    private val context: Context,
    private val folders: List<String>,
    private val onClick: (String) -> Unit = {}
) : RecyclerView.Adapter<FileManagerAdapter.ViewHolder>() {

    private val theme = ThemeManager.getTheme(context)

    inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val icon: ImageView = view.findViewById(R.id.folderIcon)
        val title: TextView = view.findViewById(R.id.folderTitle)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_folder, parent, false)
        return ViewHolder(v)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val name = folders[position]
        holder.title.text = name
        holder.title.setTextColor(theme.folderTitleColor)

        val drawableId = IconResolver.resolveFolderIcon(context, name)
        holder.icon.setImageResource(drawableId)
        ImageViewCompat.setImageTintList(holder.icon, android.content.res.ColorStateList.valueOf(theme.iconTint))

        holder.itemView.setOnClickListener { onClick(name) }
    }

    override fun getItemCount(): Int = folders.size
}
KT

cat > "$PKG_DIR/SampleFolderFragment.kt" <<'KT'
package com.k1lllagt.droidshell

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class SampleFolderFragment : Fragment() {

    private val sampleFolders = listOf(
        "bin", "plugins", "themes", "scripts", "workspace",
        "packages", "config", "logs", "DCIM", "Downloads", "Documents"
    )

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_folder_list, container, false)
        val rv = view.findViewById<RecyclerView>(R.id.folderRecyclerView)
        rv.layoutManager = LinearLayoutManager(requireContext())
        rv.adapter = FileManagerAdapter(requireContext(), sampleFolders) { folderName ->
            // handle click
        }
        return view
    }
}
KT

cat > "$PKG_DIR/DroidShellApp.kt" <<'KT'
package com.k1lllagt.droidshell

import android.app.Application
import java.io.File

class DroidShellApp : Application() {

    override fun onCreate() {
        super.onCreate()
        provisionDroidShellTree()
    }

    private fun provisionDroidShellTree() {
        val prefs = getSharedPreferences("droidshell_prefs", MODE_PRIVATE)
        if (prefs.getBoolean("tree_provisioned", false)) return

        val internalRoot = File(getExternalFilesDir(null), "DroidShell")
        val publicRoot = File("/sdcard/DroidShell")

        val dirs = listOf("bin", "plugins", "themes", "scripts", "workspace", "packages", "config", "logs")

        fun createTree(root: File) {
            root.mkdirs()
            dirs.forEach { name ->
                val d = File(root, name)
                d.mkdirs()
                val readme = File(d, "README.txt")
                if (!readme.exists()) {
                    readme.writeText(
                        "DroidShell canonical folder: $name\n" +
                        "Location: ${root.absolutePath}\n"
                    )
                }
            }
        }

        createTree(internalRoot)
        createTree(publicRoot)

        prefs.edit().putBoolean("tree_provisioned", true).apply()
    }
}
KT

cat > "$SCRIPTS_DIR/create_droidshell_tree.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

ROOT_INTERNAL="$HOME/Android/data/com.k1lllagt.droidshell/files/DroidShell"
ROOT_PUBLIC="/sdcard/DroidShell"
DIRS=(bin plugins themes scripts workspace packages config logs)

echo "Creating DroidShell tree at:"
echo " - $ROOT_INTERNAL"
echo " - $ROOT_PUBLIC"

for ROOT in "$ROOT_INTERNAL" "$ROOT_PUBLIC"; do
  mkdir -p "$ROOT"
  for d in "${DIRS[@]}"; do
    mkdir -p "$ROOT/$d"
    cat > "$ROOT/$d/README.txt" <<README
DroidShell canonical folder: $d
Location: $ROOT
README
  done
done

echo "Done."
SH

chmod +x "$SCRIPTS_DIR/create_droidshell_tree.sh"

echo "Created full DroidShell stack for com.k1lllagt.droidshell."
echo "Next:"
echo " 1) Set android:name=\".DroidShellApp\" in AndroidManifest <application>."
echo " 2) Replace placeholder SVG/XML icons with real designs via Vector Asset import."
echo " 3) Use SampleFolderFragment in your navigation graph/activity."
