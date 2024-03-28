#!/usr/bin/env bash
set -exo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/"
SKYRIM_TOGETHER_PATH="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"

# Function to copy or create a symlink
copy_or_link() {
  if [ -f "$2" ]; then
      echo "$2 already exists. Skipping..."
  else
      if sudo ln -s "$1" "$2"; then
          echo "Symlink created: $1 -> $2"
      else
          echo "Copying $1 to $2"
          sudo cp "$1" "$2"
      fi
  fi
}

str_setup() {
    echo "Contents of SKYRIM_TOGETHER_PATH:"
    ls "${SKYRIM_TOGETHER_PATH}"

    if [ -d "$1" ] &&
       [ -f "${SKYRIM_TOGETHER_PATH}/SkyrimTogether.exe" ] &&
       [ -f "${1}SkyrimSELauncher.exe" ]; then
        echo "Current directory: $(pwd)"

        echo "Renaming launcher (if needed)"
        if [ ! -f "${1}_SkyrimSELauncher.exe" ]; then
            mv "${1}SkyrimSELauncher.exe" "${1}_SkyrimSELauncher.exe" || echo "Launcher rename failed"
        fi

        echo "Symlinking SkyrimTogether.exe"
        if [ ! -L "${1}SkyrimSELauncher.exe" ]; then
            sudo ln -s "${SKYRIM_TOGETHER_PATH}/SkyrimTogether.exe" "${1}SkyrimSELauncher.exe" || echo "Failed to create launcher symlink"
        fi

        echo "Symlinking mod content"
        cd "${SKYRIM_TOGETHER_PATH}"
        find . -type f -exec bash -c '
            src="$0"
            dest="$1${src#./}"  # Remove leading ./ from src, then concatenate with the destination path
            if [ ! -L "$dest" ]; then
                sudo mkdir -p "$(dirname "$dest")"  # Create the necessary directories
                sudo ln -s "$(realpath --relative-to "$(dirname "$dest")" "$src")" "$dest" || echo "Failed to symlink $dest"
            fi
        ' {} "$1" \;
    fi
}

# Setup for both Skyrim directories
str_setup "$SKYRIM_INTERNAL"
str_setup "$SKYRIM_EXTERNAL"

# Configuration file handling
echo "Copying or linking loadorder.txt and plugins.txt"
sudo mkdir -p "$APPDATA_INTERNAL" || true
sudo mkdir -p "$APPDATA_EXTERNAL" || true

copy_or_link "$APPDATA_VORTEX/loadorder.txt" "$APPDATA_INTERNAL/loadorder.txt"
copy_or_link "$APPDATA_VORTEX/loadorder.txt" "$APPDATA_EXTERNAL/loadorder.txt"
copy_or_link "$APPDATA_VORTEX/plugins.txt" "$APPDATA_INTERNAL/plugins.txt"
copy_or_link "$APPDATA_VORTEX/plugins.txt" "$APPDATA_EXTERNAL/plugins.txt"

echo "Success! This window will close in 5 seconds....."
sleep 5
