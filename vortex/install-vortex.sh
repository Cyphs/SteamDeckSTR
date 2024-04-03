#!/usr/bin/env bash
set -euo pipefail

VORTEX_LINUX="v1.3.4"
VORTEX_VERSION="1.9.12"
PROTON_BUILD="GE-Proton8-27"

PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$PROTON_BUILD/$PROTON_BUILD.tar.gz"
VORTEX_INSTALLER="vortex-setup-$VORTEX_VERSION.exe"
VORTEX_URL="https://github.com/Nexus-Mods/Vortex/releases/download/v$VORTEX_VERSION/$VORTEX_INSTALLER"
DOTNET_URL="https://download.visualstudio.microsoft.com/download/pr/06239090-ba0c-46e2-ad3e-6491b877f481/c5e4ab5e344eb3bdc3630e7b5bc29cd7/windowsdesktop-runtime-6.0.21-win-x64.exe"

# install steam linux runtime sniper
steam steam://install/1628350

mkdir -p ~/.Cyphs/SteamDeckSTR-master/vortex/

cd ~/.Cyphs/SteamDeckSTR-master/vortex/

rm -rf vortex-linux || true
wget https://github.com/pikdum/vortex-linux/releases/download/$VORTEX_LINUX/vortex-linux
chmod +x vortex-linux

# set STEAM_RUNTIME_PATH to internal storage or sd card
if [ -f "$HOME/.steam/steam/steamapps/common/SteamLinuxRuntime_sniper/run" ]; then
    STEAM_RUNTIME_PATH="$HOME/.steam/steam/steamapps/common/SteamLinuxRuntime_sniper"
elif [ -f "/run/media/mmcblk0p1/steamapps/common/SteamLinuxRuntime_sniper/run" ]; then
    STEAM_RUNTIME_PATH="/run/media/mmcblk0p1/steamapps/common/SteamLinuxRuntime_sniper"
else
    echo "SteamLinuxRuntime Sniper not found!"
    sleep 3
    exit 1
fi

./vortex-linux setConfig STEAM_RUNTIME_PATH $STEAM_RUNTIME_PATH
./vortex-linux downloadProton "$PROTON_URL"
./vortex-linux setProton "$PROTON_BUILD"
./vortex-linux downloadVortex "$VORTEX_URL"
./vortex-linux protonRunUrl "$DOTNET_URL" /q
./vortex-linux setupVortexDesktop
./vortex-linux installVortex "$VORTEX_INSTALLER"

cd ~/.vortex-linux/compatdata/pfx/dosdevices

if [ -d "$HOME/.steam/steam/steamapps/common/" ]; then
    ln -s "$HOME/.steam/steam/steamapps/common/" j: || true
fi

if [ -d "/run/media/mmcblk0p1/steamapps/common/" ]; then
    ln -s "/run/media/mmcblk0p1/steamapps/common/" k: || true
fi

update-desktop-database || true

rm -f ~/Desktop/install-vortex.desktop
ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/
ln -sf ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-post-deploy.desktop ~/Desktop/
ln -sf ~/.Cyphs/SteamDeckSTR-master/vortex/Undo-STR.desktop ~/Desktop/

mkdir -p /run/media/mmcblk0p1/vortex-downloads || true

# Symlink all Proton versions
PROTON_DIR="/home/deck/.vortex-linux/proton-builds/"
STEAM_DIR="/home/deck/.steam/root/compatibilitytools.d/"

# Create a symlink for each Proton version
for dir in $PROTON_DIR/GE-Proton*; do
    if [ -d "$dir" ]; then
        symlink_name=$(basename "$dir")
        if [ ! -L "$STEAM_DIR/$symlink_name" ]; then
            ln -s "$dir" "$STEAM_DIR/$symlink_name"
        fi
    fi
done

# Set the Proton version for the game
INTERNAL_PATH="/home/deck/.steam/steam/steamapps/compatdata/489830/"
EXTERNAL_PATH="/run/media/mmcblk0p1/steamapps/compatdata/489830/"

echo "Setting Proton version for the game..."
if [ -d "$INTERNAL_PATH" ]; then
    echo "$PROTON_BUILD" > "${INTERNAL_PATH}version"
elif [ -d "$EXTERNAL_PATH" ]; then
    echo "$PROTON_BUILD" > "${EXTERNAL_PATH}version"
else
    echo "The game is not installed in either the internal or external location."
fi

# Define the files to backup
FILES_TO_BACKUP=("_ResourcePack.bsa" "_ResourcePack.esl" "ccBGSSSE001-Fish.bsa" "ccBGSSSE001-Fish.esm" "ccBGSSSE025-AdvDSGS.bsa" "ccBGSSSE025-AdvDSGS.esm" "ccBGSSSE037-Curios.bsa" "ccBGSSSE037-Curios.esl" "ccQDRSSE001-SurvivalMode.bsa" "ccQDRSSE001-SurvivalMode.esl")

# Define the backup directory
BACKUP_DIR="$HOME/.Cyphs/SteamDeckSTR-master/CC Backup/"

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup files from both Skyrim directories
SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/Data/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim Special Edition/Data/"

if [ -d "$SKYRIM_INTERNAL" ]; then
    echo "Backing up files from $SKYRIM_INTERNAL to $BACKUP_DIR"
    for FILE in "${FILES_TO_BACKUP[@]}"; do
        if [ -f "${SKYRIM_INTERNAL}${FILE}" ]; then
            mv "${SKYRIM_INTERNAL}${FILE}" "$BACKUP_DIR"
        fi
    done
fi

if [ -d "$SKYRIM_EXTERNAL" ]; then
    echo "Backing up files from $SKYRIM_EXTERNAL to $BACKUP_DIR"
    for FILE in "${FILES_TO_BACKUP[@]}"; do
        if [ -f "${SKYRIM_EXTERNAL}${FILE}" ]; then
            mv "${SKYRIM_EXTERNAL}${FILE}" "$BACKUP_DIR"
        fi
    done
fi

# Restart Steam
echo "Restarting Steam. Please wait..."
steam -shutdown
while pgrep -x "steam" > /dev/null; do sleep 1; done
nohup steam > /dev/null 2>&1 &

echo "Success! Exiting in 5 seconds....."
sleep 5
