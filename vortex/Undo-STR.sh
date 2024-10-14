#!/usr/bin/env bash

set -eo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL_ALT="/run/media/mmcblk0p1/SteamLibrary/steamapps/common/Skyrim Special Edition/"

APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL_ALT="/run/media/mmcblk0p1/SteamLibrary/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"

CC_BACKUP="$HOME/.Cyphs/SteamDeckSTR-master/CC Backup/"

# Array of files and directories to delete
FILES_AND_DIRS=("EarlyLoad.dll" "STServer.dll" "SkyrimTogether.exe" "SkyrimTogetherServer.exe" "TPProcess.exe" "chrome_100_percent.pak" "chrome_200_percent.pak" "chrome_elf.dll" "crashpad_handler.exe" "d3dcompiler_47.dll" "discord_game_sdk.dll" "icudtl.dat" "imgui.ini" "libEGL.dll" "libGLESv2.dll" "libcef.dll" "resources.pak" "snapshot_blob.bin" "uv.dll" "v8_context_snapshot.bin" "vk_swiftshader.dll" "vulkan-1.dll" "UI" "assets" "config" "locales" "logs" "swiftshader" "cache" ".sentry-native" "__folder_managed_by_vortex")

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

# Process all Skyrim directories
for SKYRIM_DIR in "$SKYRIM_INTERNAL" "$SKYRIM_EXTERNAL" "$SKYRIM_EXTERNAL_ALT"; do
  if [ -d "$SKYRIM_DIR" ]; then
    echo "Processing $SKYRIM_DIR"
    
    # Delete files and directories
    for FILE_OR_DIR in "${FILES_AND_DIRS[@]}"; do
      delete_file_or_dir "${SKYRIM_DIR}${FILE_OR_DIR}"
    done
    
    # Delete files that start with crash_UTC
    for FILE in "${SKYRIM_DIR}"crash_UTC*; do
      delete_file_or_dir "$FILE"
    done
    
    # Rename launcher
    rename_launcher "$SKYRIM_DIR"
    
    # Restore files from CC Backup
    for FILE in "${FILES_TO_RESTORE[@]}"; do
      restore_file "$SKYRIM_DIR" "$FILE"
    done
  else
    echo "$SKYRIM_DIR does not exist. Skipping..."
  fi
done

# Process all AppData directories
for APPDATA_DIR in "$APPDATA_INTERNAL" "$APPDATA_EXTERNAL" "$APPDATA_EXTERNAL_ALT"; do
  if [ -d "$APPDATA_DIR" ]; then
    echo "Processing $APPDATA_DIR"
    delete_file_or_dir "${APPDATA_DIR}loadorder.txt"
    delete_file_or_dir "${APPDATA_DIR}Plugins.txt"
  else
    echo "$APPDATA_DIR does not exist. Skipping..."
  fi
done

# Remove registry keys
remove_registry_keys() {
  local reg_path="$1"
  if [ -f "$reg_path" ]; then
    echo "Removing registry keys from $reg_path"
    sed -i '/\[Software\\\\TiltedPhoques\\\\TiltedEvolution\\\\Skyrim Special Edition\]/d' "$reg_path"
    sed -i '/^"TitleExe"=/d' "$reg_path"
    sed -i '/^"TitlePath"=/d' "$reg_path"
  else
    echo "$reg_path does not exist. Skipping..."
  fi
}

remove_registry_keys "$HOME/.steam/steam/steamapps/compatdata/489830/pfx/user.reg"
remove_registry_keys "/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/user.reg"
remove_registry_keys "/run/media/mmcblk0p1/SteamLibrary/steamapps/compatdata/489830/pfx/user.reg"

echo "Undo script completed. This window will close in 5 seconds....."
sleep 5
