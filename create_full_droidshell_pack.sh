#!/usr/bin/env bash
set -euo pipefail

# create_full_droidshell_pack.sh
# Single script to generate:
#  - SVG source icons and Android vector drawable XMLs
#  - Kotlin IconResolver class
#  - FileManager adapter, item layout, and sample fragment
#  - Canonical DroidShell directory tree creation script
# Usage: ./create_full_droidshell_pack.sh

PROJECT_ROOT="$(pwd)"
RES_DIR="$PROJECT_ROOT/app/src/main/res"
DRAWABLE_DIR="$RES_DIR/drawable"
RAW_DIR="$PROJECT_ROOT/app/src/main/res/raw"
KOTLIN_PKG_DIR="$PROJECT_ROOT/app/src/main/java/com/example/droidshell"
LAYOUT_DIR="$RES_DIR/layout"
ASSETS_SVG_DIR="$PROJECT_ROOT/assets/droidshell_icons/svg"
SCRIPTS_DIR="$PROJECT_ROOT/tools"

# Create directories
mkdir -p "$DRAWABLE_DIR"
mkdir -p "$RAW_DIR"
mkdir -p "$KOTLIN_PKG_DIR"
mkdir -p "$LAYOUT_DIR"
mkdir -p "$ASSETS_SVG_DIR"
mkdir -p "$SCRIPTS_DIR"

echo "Creating SVG source icons and Android vector drawables..."

# Minimal, editable SVG sources for designers
cat > "$ASSETS_SVG_DIR/ds_bin.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <rect x="2" y="4" width="20" height="16" rx="2" fill="#071E1A"/>
  <rect x="6" y="8" width="12" height="8" fill="#00FF7F"/>
  <path d="M8 10h8" stroke="#071E1A" stroke-width="1.2" stroke-linecap="round"/>
</svg>
SVG

cat > "$ASSETS_SVG_DIR/ds_plugins.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <g fill="#0AB4FF">
    <path d="M12 2l3.2 6H8.8L12 2z"/>
    <rect x="4" y="10" width="16" height="10" rx="1.5"/>
  </g>
</svg>
SVG

cat > "$ASSETS_SVG_DIR/ds_themes.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="10" fill="#FFB86B"/>
  <rect x="7" y="11" width="10" height="2" fill="#FFFFFF"/>
</svg>
SVG

cat > "$ASSETS_SVG_DIR/ds_scripts.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <rect x="3" y="3" width="18" height="18" rx="2" fill="#0B3F00"/>
  <g fill="#7CFF00">
    <rect x="7" y="8" width="10" height="2"/>
    <rect x="7" y="12" width="10" height="2"/>
  </g>
</svg>
SVG

cat > "$ASSETS_SVG_DIR/ds_workspace.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <rect x="2" y="6" width="20" height="12" rx="1.5" fill="#FFD700"/>
  <rect x="6" y="9" width="12" height="2" fill="#001F00"/>
</svg>
SVG

cat > "$ASSETS_SVG_DIR/ds_packages.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="M3 7l9-4 9 4v10l-9 4-9-4z" fill="#C0C0C0"/>
  <rect x="8" y="11" width="8" height="6" fill="#001122"/>
</svg>
SVG

cat > "$ASSETS_SVG_DIR/ds_config.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="M12 2a2 2 0 0 1 2 2v2h-4V4a2 2 0 0 1 2-2z" fill="#FF6B6B"/>
  <rect x="4" y="8" width="16" height="12" rx="1.5" fill="#FF6B6B"/>
  <rect x="8" y="12" width="8" height="2" fill="#001100"/>
</svg>
SVG

cat > "$ASSETS_SVG_DIR/ds_logs.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <rect x="3" y="3" width="18" height="18" rx="2" fill="#FFFFFF"/>
  <rect x="6" y="8" width="12" height="2" fill="#333333"/>
  <rect x="6" y="12" width="12" height="2" fill="#333333"/>
</svg>
SVG

# Create Android vector drawable XMLs based on the SVGs above.
# These are intentionally simple and editable.
cat > "$DRAWABLE_DIR/ic_droidshell_bin.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#071E1A" android:pathData="M2,4h20a2,2 0 0 1 2,2v12a2,2 0 0 1 -2,2H2a2,2 0 0 1 -2,-2V6a2,2 0 0 1 2,-2z"/>
  <path android:fillColor="#00FF7F" android:pathData="M6,8h12v8H6z"/>
  <path android:strokeColor="#071E1A" android:strokeWidth="1" android:pathData="M8,10h8"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_plugins.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#0AB4FF" android:pathData="M12,2l3.2,6H8.8L12,2z"/>
  <path android:fillColor="#0AB4FF" android:pathData="M4,10h16v10H4z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_themes.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFB86B" android:pathData="M12,2a10,10 0 1 0 0,20a10,10 0 0 0 0,-20z"/>
  <path android:fillColor="#FFFFFF" android:pathData="M7,11h10v2H7z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_scripts.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#0B3F00" android:pathData="M3,3h18v18H3z"/>
  <path android:fillColor="#7CFF00" android:pathData="M7,8h10v2H7zM7,12h10v2H7z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_workspace.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFD700" android:pathData="M2,6h20v12H2z"/>
  <path android:fillColor="#001F00" android:pathData="M6,9h12v2H6z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_packages.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#C0C0C0" android:pathData="M3,7l9,-4 9,4v10l-9,4-9,-4z"/>
  <path android:fillColor="#001122" android:pathData="M8,11h8v6H8z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_config.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FF6B6B" android:pathData="M12,2a2,2 0 0 1 2,2v2h-4V4a2,2 0 0 1 2,-2z"/>
  <path android:fillColor="#FF6B6B" android:pathData="M4,8h16v12H4z"/>
  <path android:fillColor="#001100" android:pathData="M8,12h8v2H8z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_logs.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFFFFF" android:pathData="M4,4h16v16H4z"/>
  <path android:fillColor="#333333" android:pathData="M6,8h12v2H6zM6,12h12v2H6z"/>
</vector>
XML

# Default fallback icons
cat > "$DRAWABLE_DIR/ic_folder_default.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#90A4AE" android:pathData="M3,6h6l2,2h10v10H3z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_folder_download.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#2196F3" android:pathData="M5,20h14v-2H5z"/>
  <path android:fillColor="#2196F3" android:pathData="M12,3v10l4,-4h-3V3z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_folder_documents.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#4CAF50" android:pathData="M6,2h9l5,5v13H6z"/>
  <path android:fillColor="#FFFFFF" android:pathData="M8,10h8v2H8zM8,14h8v2H8z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_folder_photos.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FF7043" android:pathData="M4,6h16v12H4z"/>
  <path android:fillColor="#FFFFFF" android:pathData="M8,10l2,3 3,-4 5,6H6z"/>
</vector>
XML

echo "Vector drawables created."

echo "Creating Kotlin IconResolver and FileManager integration code..."

cat > "$KOTLIN_PKG_DIR/IconResolver.kt" <<'KT'
package com.example.droidshell

import android.content.Context
import androidx.annotation.DrawableRes
import com.example.droidshell.R

object IconResolver {

    /**
     * Resolve a folder name to a drawable resource id.
     * Lowercases and trims the folder name before matching.
     * Extend this mapping as DroidShell evolves.
     */
    @DrawableRes
    fun resolveFolderIcon(folderName: String?): Int {
        if (folderName.isNullOrBlank()) return R.drawable.ic_folder_default

        return when (folderName.trim().lowercase()) {
            "bin", "binaries" -> R.drawable.ic_droidshell_bin
            "plugins", "extensions" -> R.drawable.ic_droidshell_plugins
            "themes", "theme" -> R.drawable.ic_droidshell_themes
            "scripts", "script" -> R.drawable.ic_droidshell_scripts
            "workspace", "work" -> R.drawable.ic_droidshell_workspace
            "packages", "pkg" -> R.drawable.ic_droidshell_packages
            "config", "configs", "settings" -> R.drawable.ic_droidshell_config
            "logs", "log" -> R.drawable.ic_droidshell_logs
            "dcim", "pictures", "photos" -> R.drawable.ic_folder_photos
            "downloads" -> R.drawable.ic_folder_download
            "documents" -> R.drawable.ic_folder_documents
            else -> R.drawable.ic_folder_default
        }
    }
}
KT

cat > "$KOTLIN_PKG_DIR/FileManagerAdapter.kt" <<'KT'
package com.example.droidshell

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class FileManagerAdapter(
    private val context: Context,
    private val folders: List<String>,
    private val onClick: (String) -> Unit = {}
) : RecyclerView.Adapter<FileManagerAdapter.ViewHolder>() {

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
        val drawableId = IconResolver.resolveFolderIcon(name)
        holder.icon.setImageResource(drawableId)
        holder.itemView.setOnClickListener { onClick(name) }
    }

    override fun getItemCount(): Int = folders.size
}
KT

cat > "$KOTLIN_PKG_DIR/SampleFolderFragment.kt" <<'KT'
package com.example.droidshell

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class SampleFolderFragment : Fragment() {

    private val sampleFolders = listOf(
        "bin", "plugins", "themes", "scripts", "workspace", "packages", "config", "logs",
        "DCIM", "Downloads", "Documents"
    )

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_folder_list, container, false)
        val rv = view.findViewById<RecyclerView>(R.id.folderRecyclerView)
        rv.layoutManager = LinearLayoutManager(requireContext())
        rv.adapter = FileManagerAdapter(requireContext(), sampleFolders) { folderName ->
            // handle folder click
        }
        return view
    }
}
KT

echo "Kotlin files created."

echo "Creating layout resources..."

cat > "$LAYOUT_DIR/item_folder.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="64dp"
    android:padding="8dp">

    <ImageView
        android:id="@+id/folderIcon"
        android:layout_width="40dp"
        android:layout_height="40dp"
        android:contentDescription="@string/folder_icon"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent"
        android:tint="?attr/colorOnSurface" />

    <TextView
        android:id="@+id/folderTitle"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:text="Folder"
        android:textAppearance="?attr/textAppearanceBody1"
        app:layout_constraintStart_toEndOf="@id/folderIcon"
        app:layout_constraintTop_toTopOf="@id/folderIcon"
        app:layout_constraintBottom_toBottomOf="@id/folderIcon"
        app:layout_constraintEnd_toEndOf="parent"
        android:paddingStart="12dp"/>

</androidx.constraintlayout.widget.ConstraintLayout>
XML

cat > "$LAYOUT_DIR/fragment_folder_list.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/folderRecyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"/>

</FrameLayout>
XML

echo "Layouts created."

echo "Creating canonical DroidShell directory tree script..."

cat > "$SCRIPTS_DIR/create_droidshell_tree.sh" <<'SH'
#!/usr/bin/env bash
# create_droidshell_tree.sh
# Creates a canonical DroidShell directory tree in the user's home DroidShell folder.
set -euo pipefail

ROOT="$HOME/DroidShell"
DIRS=(bin plugins themes scripts workspace packages config logs)

echo "Creating DroidShell directory tree at $ROOT"
mkdir -p "$ROOT"
for d in "${DIRS[@]}"; do
  mkdir -p "$ROOT/$d"
  cat > "$ROOT/$d/README.txt" <<README
DroidShell canonical folder: $d
Purpose: Describe what goes here.
README
done

echo "Directory tree created at $ROOT"
SH

chmod +x "$SCRIPTS_DIR/create_droidshell_tree.sh"

echo "Making scripts executable and finishing up..."

chmod +x "$PROJECT_ROOT/create_full_droidshell_pack.sh" || true

echo ""
echo "Summary of created files and locations:"
echo " - SVG sources: assets/droidshell_icons/svg/*.svg"
echo " - Android vector drawables: app/src/main/res/drawable/ic_droidshell_*.xml and ic_folder_*.xml"
echo " - Kotlin: app/src/main/java/com/example/droidshell/IconResolver.kt"
echo "           app/src/main/java/com/example/droidshell/FileManagerAdapter.kt"
echo "           app/src/main/java/com/example/droidshell/SampleFolderFragment.kt"
echo " - Layouts: app/src/main/res/layout/item_folder.xml"
echo "            app/src/main/res/layout/fragment_folder_list.xml"
echo " - Directory tree script: tools/create_droidshell_tree.sh"
echo ""
echo "Next steps:"
echo " 1. Import or refine SVGs in a vector editor and convert to Android vector drawables if you want more detail."
echo " 2. Add the Kotlin files to your Android Studio project and rebuild."
echo " 3. Ensure your module package name matches com.example.droidshell or move files to your package path."
echo " 4. Run tools/create_droidshell_tree.sh to create the canonical folders on your development machine."
echo ""
echo "Done."
