#!/usr/bin/env bash

set -eo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL_ALT="/run/media/mmcblk0p1/SteamLibrary/steamapps/common/Skyrim Special Edition/"
SKYRIM_TOGETHER_PATH_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"
SKYRIM_TOGETHER_PATH_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"
SKYRIM_TOGETHER_PATH_EXTERNAL_ALT="/run/media/mmcblk0p1/SteamLibrary/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL_ALT="/run/media/mmcblk0p1/SteamLibrary/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"

CC_BACKUP="$HOME/.Cyphs/SteamDeckSTR-master/CC Backup/"

FILES_TO_BACKUP=("ccBGSSSE001-Fish.bsa" "ccBGSSSE001-Fish.esm" "ccBGSSSE025-AdvDSGS.bsa" "ccBGSSSE025-AdvDSGS.esm" "ccBGSSSE037-Curios.bsa" "ccBGSSSE037-Curios.esl" "ccQDRSSE001-SurvivalMode.bsa" "ccQDRSSE001-SurvivalMode.esl")

# Function to remove and backup CC Content
backup_file() {
    if [ -f "${1}Data/${2}" ]; then
        echo "CC content found, removing ${2} and saving to CC Backup"
        mv "${1}Data/${2}" "${CC_BACKUP}/"
    fi
}

# Backup files from all Skyrim directories
for FILE in "${FILES_TO_BACKUP[@]}"; do
    [ -d "$SKYRIM_INTERNAL" ] && backup_file "$SKYRIM_INTERNAL" "$FILE"
    [ -d "$SKYRIM_EXTERNAL" ] && backup_file "$SKYRIM_EXTERNAL" "$FILE"
    [ -d "$SKYRIM_EXTERNAL_ALT" ] && backup_file "$SKYRIM_EXTERNAL_ALT" "$FILE"
done

str_setup() {
    if [ -d "$1" ] && [ -d "$2" ] && [ -f "${2}/SkyrimTogether.exe" ] && [ -f "${1}SkyrimSELauncher.exe" ]; then
        echo "Contents of SKYRIM_TOGETHER_PATH:"
        ls "$2"
        echo "Current directory: $(pwd)"
        echo "Renaming launcher (if needed)"
        [ ! -f "${1}_SkyrimSELauncher.exe" ] && mv "${1}SkyrimSELauncher.exe" "${1}_SkyrimSELauncher.exe" || echo "Launcher rename failed"
        echo "Symlinking SkyrimTogether.exe"
        [ ! -L "${1}SkyrimSELauncher.exe" ] && ln -s "${2}/SkyrimTogether.exe" "${1}SkyrimSELauncher.exe" || echo "Failed to create launcher symlink"
        echo "Symlinking mod content"
        cd "${2}"
        find . -type f -exec bash -c '
            src="$0"
            dest="$1${src#./}"
            if [ ! -L "$dest" ]; then
                mkdir -p "$(dirname "$dest")"
                ln -s "$(realpath --relative-to "$(dirname "$dest")" "$src")" "$dest" || echo "Failed to symlink $dest"
            fi
        ' {} "$1" \;
    fi
}

# Setup for all Skyrim directories
str_setup "$SKYRIM_INTERNAL" "$SKYRIM_TOGETHER_PATH_INTERNAL"
str_setup "$SKYRIM_EXTERNAL" "$SKYRIM_TOGETHER_PATH_EXTERNAL"
str_setup "$SKYRIM_EXTERNAL_ALT" "$SKYRIM_TOGETHER_PATH_EXTERNAL_ALT"

# Configuration file handling
echo "Symlinking loadorder.txt and Plugins.txt"
mkdir -p "$APPDATA_INTERNAL" "$APPDATA_EXTERNAL" "$APPDATA_EXTERNAL_ALT" || true

for APPDATA_DIR in "$APPDATA_INTERNAL" "$APPDATA_EXTERNAL" "$APPDATA_EXTERNAL_ALT"; do
    if [ -d "$APPDATA_DIR" ] && [ -d "$APPDATA_VORTEX" ]; then
        [ ! -L "$APPDATA_DIR/loadorder.txt" ] && ln -s "$APPDATA_VORTEX/loadorder.txt" "$APPDATA_DIR/loadorder.txt"
        rm -f "$APPDATA_DIR/Plugins.txt"
        ln -s "$APPDATA_VORTEX/plugins.txt" "$APPDATA_DIR/Plugins.txt"
    fi
done

# Add registry keys
USER_REG_PATH_INTERNAL="/home/deck/.steam/steam/steamapps/compatdata/489830/pfx/user.reg"
USER_REG_PATH_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/user.reg"
USER_REG_PATH_EXTERNAL_ALT="/run/media/mmcblk0p1/SteamLibrary/steamapps/compatdata/489830/pfx/user.reg"
TIMESTAMP=$(date +%s)

add_registry_keys() {
    local reg_path="$1"
    local skyrim_path="$2"
    if [ -f "$reg_path" ]; then
        echo "[Software\\\\TiltedPhoques\\\\TiltedEvolution\\\\Skyrim Special Edition] $TIMESTAMP" >> "$reg_path"
        echo "\"TitleExe\"=\"Z:\\\\\\\\${skyrim_path//\//\\\\}SkyrimSE.exe\"" >> "$reg_path"
        echo "\"TitlePath\"=\"Z:\\\\\\\\${skyrim_path//\//\\\\}\"" >> "$reg_path"
    fi
}

add_registry_keys "$USER_REG_PATH_INTERNAL" "home\\\\deck\\\\.local\\\\share\\\\Steam\\\\steamapps\\\\common\\\\Skyrim Special Edition\\\\"
add_registry_keys "$USER_REG_PATH_EXTERNAL" "run\\\\media\\\\mmcblk0p1\\\\steamapps\\\\common\\\\Skyrim Special Edition\\\\"
add_registry_keys "$USER_REG_PATH_EXTERNAL_ALT" "run\\\\media\\\\mmcblk0p1\\\\SteamLibrary\\\\steamapps\\\\common\\\\Skyrim Special Edition\\\\"

# Restart Steam
echo "Restarting Steam. Please wait..."
steam -shutdown
while pgrep -x "steam" > /dev/null; do sleep 1; done
nohup steam > /dev/null 2>&1 &

echo "Success! This window will close in 5 seconds....."
sleep 5
