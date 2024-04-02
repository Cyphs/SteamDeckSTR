#!/usr/bin/env bash
set -eo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/"
SKYRIM_TOGETHER_PATH_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"
SKYRIM_TOGETHER_PATH_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"

str_setup() {
    echo "Contents of SKYRIM_TOGETHER_PATH:"
    ls "${SKYRIM_TOGETHER_PATH_INTERNAL}"
    ls "${SKYRIM_TOGETHER_PATH_EXTERNAL}"

    if [ -d "$1" ] &&
       [ -f "${SKYRIM_TOGETHER_PATH_INTERNAL}/SkyrimTogether.exe" ] &&
       [ -f "${SKYRIM_TOGETHER_PATH_EXTERNAL}/SkyrimTogether.exe" ] &&
       [ -f "${1}SkyrimSELauncher.exe" ]; then
        echo "Current directory: $(pwd)"

        echo "Renaming launcher (if needed)"
        if [ ! -f "${1}_SkyrimSELauncher.exe" ]; then
            mv "${1}SkyrimSELauncher.exe" "${1}_SkyrimSELauncher.exe" || echo "Launcher rename failed"
        fi

        echo "Symlinking SkyrimTogether.exe"
        if [ ! -L "${1}SkyrimSELauncher.exe" ]; then
            ln -s "${SKYRIM_TOGETHER_PATH_INTERNAL}/SkyrimTogether.exe" "${1}SkyrimSELauncher.exe" || echo "Failed to create launcher symlink"
            ln -s "${SKYRIM_TOGETHER_PATH_EXTERNAL}/SkyrimTogether.exe" "${1}SkyrimSELauncher.exe" || echo "Failed to create launcher symlink"
        fi

        echo "Symlinking mod content"
        cd "${SKYRIM_TOGETHER_PATH_INTERNAL}"
        find . -type f -exec bash -c '
            src="$0"
            dest="$1${src#./}"  # Remove leading ./ from src, then concatenate with the destination path
            if [ ! -L "$dest" ]; then
                mkdir -p "$(dirname "$dest")"  # Create the necessary directories
                ln -s "$(realpath --relative-to "$(dirname "$dest")" "$src")" "$dest" || echo "Failed to symlink $dest"
            fi
        ' {} "$1" \\;

        cd "${SKYRIM_TOGETHER_PATH_EXTERNAL}"
        find . -type f -exec bash -c '
            src="$0"
            dest="$1${src#./}"  # Remove leading ./ from src, then concatenate with the destination path
            if [ ! -L "$dest" ]; then
                mkdir -p "$(dirname "$dest")"  # Create the necessary directories
                ln -s "$(realpath --relative-to "$(dirname "$dest")" "$src")" "$dest" || echo "Failed to symlink $dest"
            fi
        ' {} "$1" \\;
    fi
}

# Setup for both Skyrim directories
str_setup "$SKYRIM_INTERNAL"
str_setup "$SKYRIM_EXTERNAL"

# Configuration file handling
echo "Symlinking loadorder.txt and Plugins.txt"
mkdir -p "$APPDATA_INTERNAL" || true
mkdir -p "$APPDATA_EXTERNAL" || true

ln -s "$APPDATA_VORTEX/loadorder.txt" "$APPDATA_INTERNAL/loadorder.txt"
ln -s "$APPDATA_VORTEX/loadorder.txt" "$APPDATA_EXTERNAL/loadorder.txt"
ln -s "$APPDATA_VORTEX/plugins.txt" "$APPDATA_INTERNAL/Plugins.txt"
ln -s "$APPDATA_VORTEX/plugins.txt" "$APPDATA_EXTERNAL/Plugins.txt"

# Restart Steam
echo "Restarting Steam..."
killall -s SIGTERM steam || true
echo "Waiting for 3 seconds before reopening Steam..."
sleep 3
xdg-open /usr/share/applications/steam.desktop

echo "Success! This window will close in 5 seconds....."
sleep 5
