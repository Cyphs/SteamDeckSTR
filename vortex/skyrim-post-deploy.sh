#!/usr/bin/env bash
set -euxo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/"

str_setup() {
    SKYRIM_TOGETHER_PATH="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"
    echo "Contents of SKYRIM_TOGETHER_PATH:"
    ls "${SKYRIM_TOGETHER_PATH}"
    if [ -d "$1" ] &&
        [ -f "${SKYRIM_TOGETHER_PATH}/SkyrimTogether.exe" ] &&
        [ -f "${1}SkyrimSELauncher.exe" ]; then
        cd "$1"
        echo "Current directory: $(pwd)"
        if ! cmp --silent -- "${SKYRIM_TOGETHER_PATH}/SkyrimTogether.exe" "SkyrimSELauncher.exe"; then
            echo "Creating a symlink for SkyrimSELauncher.exe to SkyrimTogether.exe"
            if sudo mv SkyrimSELauncher.exe _SkyrimSELauncher.exe; then
                echo "Rename successful"
            else
                echo "Rename failed"
            fi
            if sudo ln -s "${SKYRIM_TOGETHER_PATH}/SkyrimTogether.exe" SkyrimSELauncher.exe; then
                echo "Symlink creation successful"
            else
                echo "Symlink creation failed"
            fi
        fi
        # Create symbolic links for all files and directories in the SkyrimTogetherReborn folder
        find "${SKYRIM_TOGETHER_PATH}" -mindepth 1 -exec bash -c '
            for pathname do
                src="$pathname"
                dest="${pathname/#"$SKYRIM_TOGETHER_PATH"/"."}"
                if [[ -d $src ]]; then
                    mkdir -p "$dest"
                else
                    ln -s "$src" "$dest"
                fi
            done' bash {} +
    fi
}

str_setup "$SKYRIM_INTERNAL"
str_setup "$SKYRIM_EXTERNAL"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"

echo "Copying or linking loadorder.txt and plugins.txt"
sudo mkdir -p "$APPDATA_INTERNAL" || true
sudo mkdir -p "$APPDATA_EXTERNAL" || true
copy_or_link "$APPDATA_VORTEX/loadorder.txt" "$APPDATA_INTERNAL/loadorder.txt" || true
copy_or_link "$APPDATA_VORTEX/loadorder.txt" "$APPDATA_EXTERNAL/loadorder.txt" || true
copy_or_link "$APPDATA_VORTEX/plugins.txt" "$APPDATA_INTERNAL/plugins.txt" || true
copy_or_link "$APPDATA_VORTEX/plugins.txt" "$APPDATA_EXTERNAL/plugins.txt" || true

echo "Success! This window will close in 5 seconds....."
sleep 5
