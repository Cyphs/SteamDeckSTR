#!/usr/bin/env bash
set -eo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL_1="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/"
SKYRIM_EXTERNAL_2="/run/media/mmcblk0p1/SteamLibrary/steamapps/common/Skyrim Special Edition/"
SKYRIM_TOGETHER_PATH_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"
SKYRIM_TOGETHER_PATH_EXTERNAL_1="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"
SKYRIM_TOGETHER_PATH_EXTERNAL_2="/run/media/mmcblk0p1/SteamLibrary/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL_1="/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
APPDATA_EXTERNAL_2="/run/media/mmcblk0p1/SteamLibrary/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
CC_BACKUP="$HOME/.Cyphs/SteamDeckSTR-master/CC Backup/"
FILES_TO_BACKUP=("ccBGSSSE001-Fish.bsa" "ccBGSSSE001-Fish.esm" "ccBGSSSE025-AdvDSGS.bsa" "ccBGSSSE025-AdvDSGS.esm" "ccBGSSSE037-Curios.bsa" "ccBGSSSE037-Curios.esl" "ccQDRSSE001-SurvivalMode.bsa" "ccQDRSSE001-SurvivalMode.esl")

# Function to remove and backup CC Content
backup_file() {
  if [ -f "${1}Data/${2}" ]; then
      echo "CC content found, removing ${2} and saving to CC Backup"
      mv "${1}Data/${2}" "${CC_BACKUP}/"
  fi
}

# Backup files from both Skyrim directories
for FILE in "${FILES_TO_BACKUP[@]}"; do
    if [ -d "$SKYRIM_INTERNAL" ]; then
        backup_file "$SKYRIM_INTERNAL" "$FILE"
    fi
    if [ -d "$SKYRIM_EXTERNAL_1" ]; then
        backup_file "$SKYRIM_EXTERNAL_1" "$FILE"
    fi
    if [ -d "$SKYRIM_EXTERNAL_2" ]; then
        backup_file "$SKYRIM_EXTERNAL_2" "$FILE"
    fi
done

str_setup() {
    if [ -d "$1" ] && [ -d "$2" ] && [ -f "${2}/SkyrimTogether.exe" ] && [ -f "${1}SkyrimSELauncher.exe" ]; then
        echo "Contents of SKYRIM_TOGETHER_PATH:"
        ls "$2"
        echo "Current directory: $(pwd)"

        echo "Renaming launcher (if needed)"
        if [ ! -f "${1}_SkyrimSELauncher.exe" ]; then
            mv "${1}SkyrimSELauncher.exe" "${1}_SkyrimSELauncher.exe" || echo "Launcher rename failed"
        fi

        echo "Symlinking SkyrimTogether.exe"
        if [ ! -L "${1}SkyrimSELauncher.exe" ]; then
            ln -s "${2}/SkyrimTogether.exe" "${1}SkyrimSELauncher.exe" || echo "Failed to create launcher symlink"
        fi

        echo "Symlinking mod content"
        cd "${2}"
        find . -type f -exec bash -c '
            src="$0"
            dest="$1${src#./}"  # Remove leading ./ from src, then concatenate with the destination path
            if [ ! -L "$dest" ]; then
                mkdir -p "$(dirname "$dest")"  # Create the necessary directories
                ln -s "$(realpath --relative-to "$(dirname "$dest")" "$src")" "$dest" || echo "Failed to symlink $dest"
            fi
        ' {} "$1" \;
    fi
}

# Setup for both Skyrim directories
str_setup "$SKYRIM_INTERNAL" "$SKYRIM_TOGETHER_PATH_INTERNAL"
str_setup "$SKYRIM_EXTERNAL_1" "$SKYRIM_TOGETHER_PATH_EXTERNAL_1"
str_setup "$SKYRIM_EXTERNAL_2" "$SKYRIM_TOGETHER_PATH_EXTERNAL_2"

# Configuration file handling
echo "Symlinking loadorder.txt and Plugins.txt"
if [ -d "$APPDATA_INTERNAL" ] && [ -d "$APPDATA_VORTEX" ]; then
    mkdir -p "$APPDATA_INTERNAL" || true
    if [ ! -L "$APPDATA_INTERNAL/loadorder.txt" ]; then
        ln -s "$APPDATA_VORTEX/loadorder.txt" "$APPDATA_INTERNAL/loadorder.txt"
    fi
    rm -f "$APPDATA_INTERNAL/Plugins.txt"
    ln -s "$APPDATA_VORTEX/plugins.txt" "$APPDATA_INTERNAL/Plugins.txt"
fi

if [ -d "$APPDATA_EXTERNAL_1" ] && [ -d "$APPDATA_VORTEX" ]; then
    mkdir -p "$APPDATA_EXTERNAL_1" || true
    if [ ! -L "$APPDATA_EXTERNAL_1/loadorder.txt" ]; then
        ln -s "$APPDATA_VORTEX/loadorder.txt" "$APPDATA_EXTERNAL_1/loadorder.txt"
    fi
    rm -f "$APPDATA_EXTERNAL_1/Plugins.txt"
    ln -s "$APPDATA_VORTEX/plugins.txt" "$APPDATA_EXTERNAL_1/plugins.txt"
fi

if [ -d "$APPDATA_EXTERNAL_2" ] && [ -d "$APPDATA_VORTEX" ]; then
    mkdir -p "$APPDATA_EXTERNAL_2" || true
    if [ ! -L "$APPDATA_EXTERNAL_2/loadorder.txt" ]; then
        ln -s "$APPDATA_VORTEX/loadorder.txt" "$APPDATA_EXTERNAL_2/loadorder.txt"
    fi
    rm -f "$APPDATA_EXTERNAL_2/Plugins.txt"
    ln -s "$APPDATA_VORTEX/plugins.txt" "$APPDATA_EXTERNAL_2/plugins.txt"
fi

# Add registry keys based on found path

USER_REG_PATH=""
if [ -d "$SKYRIM_INTERNAL" ]; then
    USER_REG_PATH="/home/deck/.steam/steam/steamapps/compatdata/489830/pfx/user.reg"
elif [ -d "$SKYRIM_EXTERNAL_1" ]; then
    USER_REG_PATH="/run/media/mmcblk0p1/steamapps/compatdata/489830/pfx/user.reg"
elif [ -d "$SKYRIM_EXTERNAL_2" ]; then
    USER_REG_PATH="/run/media/mmcblk0p1/SteamLibrary/steamapps/compatdata/489830/pfx/user.reg"
fi

TIMESTAMP=$(date +%s)

if [[ $USER_REG_PATH ]]; then 
    echo "[Software\\\\TiltedPhoques\\\\TiltedEvolution\\\\Skyrim Special Edition] $TIMESTAMP" >>"$USER_REG_PATH"

    if [[ $USER_REG_PATH == *"$SKYRIM_INTERNAL"* ]]; then 
        echo "\"TitleExe\"=\"Z:\\\\\\\\home\\\\\\\\deck\\\\\\\\.local\\\\\\\\share\\\\\\\\Steam\\\\\\\\steamapps\\\\\\\\common\\\\\\\\Skyrim Special Edition\\\\\\\\SkyrimSE.exe\"" >>"$USER_REG_PATH"
        echo "\"TitlePath\"=\"Z:\\\\\\\\home\\\\\\\\deck\\\\\\\\.local\\\\\\\\share\\\\\\\\Steam\\\\\\\\steamapps\\\\\\\\common\\\\\\\\Skyrim Special Edition\"" >>"$USER_REG_PATH"

    elif [[ $USER_REG_PATH == *"$SKYRIM_EXTERNAL_1"* ]]; then 
        echo "\"TitleExe\"=\"Z:\\\\\\\\run\\\\\\\\media\\\\\\\\mmcblk0p1\\\\\\\\steamapps\\\\\\\\common\\\\\\\\Skyrim Special Edition\\\\\\\\SkyrimSE.exe\"" >>"$USER_REG_PATH"
        echo "\"TitlePath\"=\"Z:\\\\\\\\run\\\\\\\\media\\\\\\\\mmcblk0p1\\\\\\\\steamapps\\\\\\\\common\\\\\\\\Skyrim Special Edition\"" >>"$USER_REG_PATH"

    elif [[ $USER_REG_PATH == *"$SKYRIM_EXTERNAL_2"* ]]; then 
        echo "\"TitleExe\"=\"Z:\\\\\\\\run\\\\\\\\media\\\\\\\\mmcblk0p1\\\\\\\\SteamLibrary\\\\\\\\steamapps\\\\\\\\common\\\\\\\\Skyrim Special Edition\\\\\\\\SkyrimSE.exe\"" >>"$USER_REG_PATH"
        echo "\"TitlePath\"=\"Z:\\\\\\\\run\\\\\\\\media\\\\\\\\mmcblk0p1\\\\\\\\SteamLibrary\\\\\\\\steamapps\\\\\\\\common\\\\\\\\Skyrim Special Edition\"" >>"$USER_REG_PATH"

    fi 
fi 

# Restart Steam
echo "Restarting Steam. Please wait..."
steam -shutdown 
while pgrep -x "steam"> /dev/null; do sleep  1; done 
nohup steam > /dev/null  2>&  1 & 

echo "Success! This window will close in 5 seconds....."
sleep 5 
