#!/usr/bin/env bash
set -eo pipefail

source ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-paths.sh

if [ -z "$SKYRIM_LIBRARY" ]; then
    echo "Skyrim Special Edition is not installed in any Steam library."
    sleep 5
    exit 1
fi
echo "Skyrim Special Edition found in $SKYRIM_LIBRARY"

CC_BACKUP="$HOME/.Cyphs/SteamDeckSTR-master/CC Backup/"

# Array of files and directories to delete
FILES_AND_DIRS=("EarlyLoad.dll" "STServer.dll" "SkyrimTogether.exe" "SkyrimTogetherServer.exe" "TPProcess.exe" "chrome_100_percent.pak" "chrome_200_percent.pak" "chrome_elf.dll" "crashpad_handler.exe" "d3dcompiler_47.dll" "discord_game_sdk.dll" "icudtl.dat" "imgui.ini" "libEGL.dll" "libGLESv2.dll" "libcef.dll" "resources.pak" "snapshot_blob.bin" "uv.dll" "v8_context_snapshot.bin" "vk_swiftshader.dll" "vulkan-1.dll" "dxcompiler.dll" "dxil.dll" "cef_debug.log" "steamnetworkingsockets.log" "steam_appid.txt" "UI" "assets" "config" "locales" "logs" "resources" "swiftshader" "cache" ".sentry-native" "__folder_managed_by_vortex")

# Array of files to restore
FILES_TO_RESTORE=("ccBGSSSE001-Fish.bsa" "ccBGSSSE001-Fish.esm" "ccBGSSSE025-AdvDSGS.bsa" "ccBGSSSE025-AdvDSGS.esm" "ccBGSSSE037-Curios.bsa" "ccBGSSSE037-Curios.esl" "ccQDRSSE001-SurvivalMode.bsa" "ccQDRSSE001-SurvivalMode.esl")

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

# Function to restore a file
restore_file() {
  if [ -f "${CC_BACKUP}/${2}" ] && [ -d "${1}Data/" ]; then
      echo "Restoring ${2}"
      mv "${CC_BACKUP}/${2}" "${1}Data/${2}"
  fi
}


# Delete Skyrim Together Reborn files from the game folder
for FILE_OR_DIR in "${FILES_AND_DIRS[@]}"; do
    delete_file_or_dir "${SKYRIM_DIR}${FILE_OR_DIR}"
done

# Delete files that start with crash_UTC
for FILE in "${SKYRIM_DIR}"crash_UTC*; do
    delete_file_or_dir "$FILE"
done

# Delete loadorder.txt and Plugins.txt symlinks
delete_file_or_dir "${SKYRIM_APPDATA}loadorder.txt"
delete_file_or_dir "${SKYRIM_APPDATA}Plugins.txt"

# Rename _SkyrimSELauncher.exe back to SkyrimSELauncher.exe (replaces the SkyrimTogether.exe link)
rename_launcher "$SKYRIM_DIR"

# Restore files from CC Backup
for FILE in "${FILES_TO_RESTORE[@]}"; do
    restore_file "$SKYRIM_DIR" "$FILE"
done

# Remove the F3/F4 launch option STR Post-Deploy added (Steam has to be closed to change it)
if pgrep -x "steam" > /dev/null; then
    echo "Restarting Steam. Please wait..."
    steam -shutdown || true
    while pgrep -x "steam" > /dev/null; do sleep 1; done
    STEAM_WAS_RUNNING=1
fi
python3 ~/.Cyphs/SteamDeckSTR-master/vortex/set-launch-option.py remove "$STEAM_ROOT" "$SKYRIM_APPID" "SteamGameId=302190" || true
if [ -n "${STEAM_WAS_RUNNING:-}" ]; then
    nohup steam > /dev/null 2>&1 &
fi

echo "Undo script completed. This window will close in 5 seconds....."
sleep 5
