#!/usr/bin/env bash
set -euo pipefail

# Usage: ./create_droidshell_assets.sh
# Creates drawable vector icons, Kotlin resolver, file manager adapter snippet, and directory tree script.

BASE_RES_DIR="app/src/main/res"
DRAWABLE_DIR="$BASE_RES_DIR/drawable"
KOTLIN_DIR="app/src/main/java/com/example/droidshell"
SCRIPTS_DIR="tools"

mkdir -p "$DRAWABLE_DIR"
mkdir -p "$KOTLIN_DIR"
mkdir -p "$SCRIPTS_DIR"

echo "Creating vector drawables..."

cat > "$DRAWABLE_DIR/ic_droidshell_bin.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path
    android:fillColor="#00FF7F"
    android:pathData="M3,3h18v18H3z"/>
  <path
    android:fillColor="#000000"
    android:strokeWidth="1"
    android:strokeColor="#001100"
    android:pathData="M7,17v-2h10v2M7,7v6h10V7zM9,9h6" />
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_droidshell_plugins.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#0AB4FF" android:pathData="M12 2L15 8H9L12 2Z"/>
  <path android:fillColor="#00A0FF" android:pathData="M4 10h16v10H4z"/>
  <path android:fillColor="#001F3F" android:pathData="M8 14h8v2H8z"/>
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_droidshell_themes.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFB86B" android:pathData="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20z"/>
  <path android:fillColor="#FFFFFF" android:pathData="M7 12h10v2H7z"/>
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_droidshell_scripts.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#7CFF00" android:pathData="M4 4h16v16H4z"/>
  <path android:fillColor="#001100" android:pathData="M8 8h8v2H8zM8 12h8v2H8z"/>
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_droidshell_workspace.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFD700" android:pathData="M3 7h18v10H3z"/>
  <path android:fillColor="#001F00" android:pathData="M6 10h12v2H6z"/>
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_droidshell_packages.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#C0C0C0" android:pathData="M3 7l9-4 9 4v10l-9 4-9-4z"/>
  <path android:fillColor="#001122" android:pathData="M8 11h8v6H8z"/>
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_droidshell_config.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FF6B6B" android:pathData="M12 2a2 2 0 0 1 2 2v2h-4V4a2 2 0 0 1 2-2z"/>
  <path android:fillColor="#FF6B6B" android:pathData="M4 8h16v12H4z"/>
  <path android:fillColor="#001100" android:pathData="M8 12h8v2H8z"/>
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_droidshell_logs.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFFFFF" android:pathData="M4 4h16v16H4z"/>
  <path android:fillColor="#333333" android:pathData="M6 8h12v2H6zM6 12h12v2H6z"/>
</vector>
EOF

echo "Drawable icons created."

echo "Creating Kotlin icon resolver class..."

cat > "$KOTLIN_DIR/IconResolver.kt" <<'EOF'
package com.example.droidshell

import android.content.Context
import androidx.annotation.DrawableRes
import com.example.droidshell.R

object IconResolver {

    /**
     * Resolve a folder name to a drawable resource id.
     * Lowercases and trims the folder name before matching.
     * Add or modify mappings here to extend DroidShell's icon set.
     */
    @DrawableRes
    fun resolveFolderIcon(context: Context, folderName: String?): Int {
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
            // common Android folders fallback examples
            "dcim", "pictures", "photos" -> R.drawable.ic_folder_photos
            "downloads" -> R.drawable.ic_folder_download
            "documents" -> R.drawable.ic_folder_documents
            else -> R.drawable.ic_folder_default
        }
    }
}
EOF

echo "Kotlin resolver created."

echo "Creating FileManager adapter snippet..."

cat > "$KOTLIN_DIR/FileManagerAdapter.kt" <<'EOF'
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
    private val folders: List<String>
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

        // Use IconResolver to pick the correct drawable
        val drawableId = IconResolver.resolveFolderIcon(context, name)
        holder.icon.setImageResource(drawableId)
    }

    override fun getItemCount(): Int = folders.size
}
EOF

echo "Adapter snippet created."

echo "Creating canonical directory tree script..."

cat > "$SCRIPTS_DIR/create_droidshell_tree.sh" <<'EOF'
#!/usr/bin/env bash
# Creates a canonical DroidShell directory tree in the user's home DroidShell folder.
set -euo pipefail

ROOT="$HOME/DroidShell"
DIRS=(bin plugins themes scripts workspace packages config logs)

echo "Creating DroidShell directory tree at $ROOT"
mkdir -p "$ROOT"
for d in "${DIRS[@]}"; do
  mkdir -p "$ROOT/$d"
  # add a README to each folder for discoverability
  cat > "$ROOT/$d/README.txt" <<README
This is the DroidShell canonical folder: $d
Purpose: Describe what goes here.
README
done

echo "Directory tree created."
EOF

chmod +x "$SCRIPTS_DIR/create_droidshell_tree.sh"

echo "Creating default folder drawables placeholders (ic_folder_default, ic_folder_download, ic_folder_documents, ic_folder_photos)..."

cat > "$DRAWABLE_DIR/ic_folder_default.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#90A4AE" android:pathData="M3 6h6l2 2h10v10H3z"/>
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_folder_download.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#2196F3" android:pathData="M5 20h14v-2H5z"/>
  <path android:fillColor="#2196F3" android:pathData="M12 3v10l4-4h-3V3z"/>
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_folder_documents.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#4CAF50" android:pathData="M6 2h9l5 5v13H6z"/>
  <path android:fillColor="#FFFFFF" android:pathData="M8 10h8v2H8zM8 14h8v2H8z"/>
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_folder_photos.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FF7043" android:pathData="M4 6h16v12H4z"/>
  <path android:fillColor="#FFF" android:pathData="M8 10l2 3 3-4 5 6H6z"/>
</vector>
EOF

echo "Placeholders created."

echo "All files created. Summary:"
echo " - Drawables: $DRAWABLE_DIR/ic_droidshell_*.xml and ic_folder_*.xml"
echo " - Kotlin: $KOTLIN_DIR/IconResolver.kt and FileManagerAdapter.kt"
echo " - Scripts: $SCRIPTS_DIR/create_droidshell_tree.sh"
echo ""
echo "Next steps:"
echo " 1. Add the drawables to your Android Studio project and rebuild."
echo " 2. Wire FileManagerAdapter into your RecyclerView and ensure item_folder layout has folderIcon and folderTitle views."
echo " 3. Run tools/create_droidshell_tree.sh to create the canonical folders on a device or emulator (or adapt to app install-time provisioning)."

exit 0
