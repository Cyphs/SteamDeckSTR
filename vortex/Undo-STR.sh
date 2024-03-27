#!/usr/bin/env bash
set -euxo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/"

undo_setup() {
    SKYRIM_TOGETHER_PATH="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"
    echo "Contents of SKYRIM_TOGETHER_PATH:"
    ls "${SKYRIM_TOGETHER_PATH}"
    if [ -d "$1" ] &&
        [ -L "${1}SkyrimSELauncher.exe" ] &&
        [ -f "${1}_SkyrimSELauncher.exe" ]; then
        cd "$1"
        echo "Current directory: $(pwd)"
        echo "Removing symlink for SkyrimSELauncher.exe and renaming _SkyrimSELauncher.exe back to SkyrimSELauncher.exe"
        if sudo rm SkyrimSELauncher.exe; then
            echo "Symlink removal successful"
        else
            echo "Symlink removal failed"
        fi
        if sudo mv _SkyrimSELauncher.exe SkyrimSELauncher.exe; then
            echo "Rename successful"
        else
            echo "Rename failed"
        fi
        # Remove symbolic links for all files and directories in the SkyrimTogetherReborn folder
        find "${SKYRIM_TOGETHER_PATH}" -mindepth 1 -exec bash -c '
            for pathname do
                src="$pathname"
                dest="${pathname/#"$SKYRIM_TOGETHER_PATH"/"."}"
                if [ -L "$dest" ]; then
                    echo "Removing symlink for $dest"
                    if sudo rm "$dest"; then
                        echo "Symlink removal successful"
                    else
                        echo "Symlink removal failed"
                    fi
                fi
            done' bash {} +
    fi
}

undo_setup "$SKYRIM_INTERNAL"
undo_setup "$SKYRIM_EXTERNAL"

echo "Uninstall successful! This window will close in 5 seconds....."
sleep 5
