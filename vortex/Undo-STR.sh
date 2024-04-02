#!/usr/bin/env bash
set -eo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/"

# Array of files and directories to delete
FILES_AND_DIRS=("EarlyLoad.dll" "STServer.dll" "SkyrimTogether.exe" "SkyrimTogetherServer.exe" "TPProcess.exe" "chrome_100_percent.pak" "chrome_200_percent.pak" "chrome_elf.dll" "crashpad_handler.exe" "d3dcompiler_47.dll" "discord_game_sdk.dll" "icudtl.dat" "imgui.ini" "libEGL.dll" "libGLESv2.dll" "libcef.dll" "resources.pak" "snapshot_blob.bin" "uv.dll" "v8_context_snapshot.bin" "vk_swiftshader.dll" "vulkan-1.dll" "UI" "assets" "config" "locales" "logs" "swiftshader" "cache" ".sentry-native" "__folder_managed_by_vortex")

# Function to delete a file or directory
delete_file_or_dir() {
  if [ -e "$1" ]; then
      echo "Deleting $1"
      rm -rf "$1"
  else
      echo "$1 does not exist. Skipping..."
  fi
}

# Function to rename _SkyrimSELauncher.exe back to SkyrimSELauncher.exe
rename_launcher() {
  if [ -f "${1}_SkyrimSELauncher.exe" ]; then
      echo "Renaming ${1}_SkyrimSELauncher.exe back to ${1}SkyrimSELauncher.exe"
      mv "${1}_SkyrimSELauncher.exe" "${1}SkyrimSELauncher.exe"
  else
      echo "${1}_SkyrimSELauncher.exe does not exist. Skipping..."
  fi
}

# Delete files and directories from both Skyrim directories
for FILE_OR_DIR in "${FILES_AND_DIRS[@]}"; do
    delete_file_or_dir "${SKYRIM_INTERNAL}${FILE_OR_DIR}"
    delete_file_or_dir "${SKYRIM_EXTERNAL}${FILE_OR_DIR}"
done

# Rename _SkyrimSELauncher.exe back to SkyrimSELauncher.exe in both Skyrim directories
rename_launcher "$SKYRIM_INTERNAL"
rename_launcher "$SKYRIM_EXTERNAL"

echo "Undo script completed. This window will close in 5 seconds....."
sleep 5
