#!/usr/bin/env sh
set -euxo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/"

skse_setup() {
    if [ -d "$1" ]; then
        cd "$1"
        if ! cmp --silent -- "skse64_loader.exe" "SkyrimSELauncher.exe"; then
            echo "Swapping SkyrimSELauncher.exe for skse64_loader.exe"
            mv SkyrimSELauncher.exe _SkyrimSELauncher.exe
            cp skse64_loader.exe SkyrimSELauncher.exe
        fi
    fi
}

skse_setup "$SKYRIM_INTERNAL"
skse_setup "$SKYRIM_EXTERNAL"

APPDATA_VORTEX="$HOME/.config/steamtinkerlaunch/vortex/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"

echo "Copying loadorder.txt and plugins.txt"
cp "$APPDATA_VORTEX"/* "$APPDATA_INTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_EXTERNAL" || true

echo "Success! Exiting in 3..."
sleep 3