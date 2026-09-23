#!/usr/bin/env bash
set -euo pipefail

source ~/.Cyphs/SteamDeckSTR-master/vortex/quiet.sh install-vortex
say "Install Vortex"
say "This takes a few minutes. Steam will restart when it's done."
say ""

source ~/.Cyphs/SteamDeckSTR-master/vortex/versions.sh

VORTEX_INSTALLER="vortex-setup-$VORTEX_VERSION.exe"
VORTEX_URL="https://github.com/Nexus-Mods/Vortex/releases/download/v$VORTEX_VERSION/$VORTEX_INSTALLER"

export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx"

mkdir -p ~/.Cyphs/SteamDeckSTR-master/vortex/
cd ~/.Cyphs/SteamDeckSTR-master/vortex/

# Install umu-launcher, which runs Vortex with its own UMU-Proton
if ! umu_up_to_date; then
    say "Installing umu-launcher..."
    ./install-umu.sh
fi

# Install GE-Proton for Skyrim, selected for it in Steam at the end
if ! proton_up_to_date; then
    say "Downloading $PROTON_BUILD (about 500 MB)..."
    ./install-proton.sh
fi

# Download Vortex installer
say "Downloading Vortex $VORTEX_VERSION and .NET..."
python3 ./download.py "$VORTEX_URL" "$VORTEX_INSTALLER"

# Install .NET runtime
python3 ./download.py "$DOTNET_URL" dotnet-runtime.exe
say "Installing .NET and Vortex (Proton downloads its files the first time, so this part is the slowest)..."
"$UMU_DIR/umu-run" dotnet-runtime.exe /q

# Install Vortex
"$UMU_DIR/umu-run" "$VORTEX_INSTALLER" /S
rm -f "$VORTEX_INSTALLER" dotnet-runtime.exe

# Create desktop file
mkdir -p ~/.local/share/applications
cp ~/.Cyphs/SteamDeckSTR-master/vortex/vortex.desktop ~/.local/share/applications/

# Let Vortex use the game's own INI files and saves
~/.Cyphs/SteamDeckSTR-master/vortex/link-my-games.sh

source ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-paths.sh

# J: is internal storage games, K: is the Steam library Skyrim is installed in when that's the SD card or another drive
cd "$WINEPREFIX/dosdevices"

if [ -d "$HOME/.steam/steam/steamapps/common/" ]; then
    ln -sfn "$HOME/.steam/steam/steamapps/common/" j:
fi

if [ -n "$SKYRIM_LIBRARY" ] && [ "$(realpath "$SKYRIM_LIBRARY")" != "$(realpath "$STEAM_ROOT")" ]; then
    ln -sfn "$SKYRIM_LIBRARY/steamapps/common/" k:
fi

# Vortex 2.x needs Steam's library list inside its own prefix
python3 ~/.Cyphs/SteamDeckSTR-master/vortex/link-steam-libraries.py "$STEAM_ROOT/steamapps/libraryfolders.vdf" "$HOME/.vortex-linux/compatdata/pfx" || true

say "Setting up Vortex for Skyrim Special Edition..."
wait_for_vortex_closed

# Preset the Skyrim folder, game store, staging folder, hardlink deployment and
# no automatic updates in Vortex, using the drive letter of Skyrim's library
PRESET_DRIVE=""
if [ -n "$SKYRIM_LIBRARY" ]; then
    if [ "$(realpath "$SKYRIM_LIBRARY")" = "$(realpath "$STEAM_ROOT")" ]; then
        PRESET_DRIVE="J"
    else
        PRESET_DRIVE="K"
    fi
fi
python3 ~/.Cyphs/SteamDeckSTR-master/vortex/preset-vortex.py "$WINEPREFIX/drive_c/sdstr-preset.bat" $PRESET_DRIVE
timeout 600 "$UMU_DIR/umu-run" cmd.exe /c "C:\\sdstr-preset.bat" || echo "Could not preset Vortex settings, set them in Vortex instead."
rm -f "$WINEPREFIX/drive_c/sdstr-preset.bat"

update-desktop-database ~/.local/share/applications || true

rm -f ~/Desktop/install-vortex.desktop
ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/
ln -sf ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-post-deploy.desktop ~/Desktop/
ln -sf ~/.Cyphs/SteamDeckSTR-master/vortex/Undo-STR.desktop ~/Desktop/

say "Backing up the Creation Club content..."

# Back up and remove the included Creation Club content
FILES_TO_BACKUP=("ccBGSSSE001-Fish.bsa" "ccBGSSSE001-Fish.esm" "ccBGSSSE025-AdvDSGS.bsa" "ccBGSSSE025-AdvDSGS.esm" "ccBGSSSE037-Curios.bsa" "ccBGSSSE037-Curios.esl" "ccQDRSSE001-SurvivalMode.bsa" "ccQDRSSE001-SurvivalMode.esl")
BACKUP_DIR="$HOME/.Cyphs/SteamDeckSTR-master/CC Backup/"
mkdir -p "$BACKUP_DIR"

if [ -n "$SKYRIM_LIBRARY" ]; then
    echo "Backing up files from ${SKYRIM_DIR}Data/ to $BACKUP_DIR"
    for FILE in "${FILES_TO_BACKUP[@]}"; do
        if [ -f "${SKYRIM_DIR}Data/${FILE}" ]; then
            mv "${SKYRIM_DIR}Data/${FILE}" "$BACKUP_DIR"
        fi
    done
else
    echo "Skyrim Special Edition is not installed in any Steam library, skipping the CC content backup."
fi

# Restart Steam, selecting GE-Proton for Skyrim while it's closed
say "Restarting Steam, please wait..."
steam -shutdown || true
while pgrep -x "steam" > /dev/null; do sleep 1; done
python3 ~/.Cyphs/SteamDeckSTR-master/vortex/set-compat-tool.py "$STEAM_ROOT/config/config.vdf" "$SKYRIM_APPID" "$PROTON_DIR" || echo "Could not select $PROTON_DIR for Skyrim, pick it in Steam instead."
nohup steam > /dev/null 2>&1 &

say ""
say "Done! Vortex is installed. Follow the next steps in the README or video."
sleep 5
