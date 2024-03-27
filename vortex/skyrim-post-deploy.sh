#!/usr/bin/env bash
set -euxo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/"

str_setup() {
    SKYRIM_TOGETHER_PATH="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/Data/Skyrim Together Reborn/SkyrimTogetherReborn"
    if [ -d "$1" ] &&
        [ -f "${SKYRIM_TOGETHER_PATH}/SkyrimTogether.exe" ] &&
        [ -f "${1}SkyrimSELauncher.exe" ]; then
        cd "$1"
        if ! cmp --silent -- "${SKYRIM_TOGETHER_PATH}/SkyrimTogether.exe" "SkyrimSELauncher.exe"; then
            echo "Creating a symlink for SkyrimSELauncher.exe to SkyrimTogether.exe"
            mv SkyrimSELauncher.exe _SkyrimSELauncher.exe
            ln -s "${SKYRIM_TOGETHER_PATH}/SkyrimTogether.exe" SkyrimSELauncher.exe
        fi
    fi
}

str_setup "$SKYRIM_INTERNAL"
str_setup "$SKYRIM_EXTERNAL"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"

echo "Copying loadorder.txt and plugins.txt"
mkdir -p "$APPDATA_INTERNAL" || true
mkdir -p "$APPDATA_EXTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_INTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_EXTERNAL" || true

echo "Success! Exiting in 3..."
sleep 3
