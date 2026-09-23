#!/usr/bin/env bash
set -eo pipefail

source ~/.Cyphs/SteamDeckSTR-master/vortex/quiet.sh post-deploy
say "STR Post-Deploy"
say ""

source ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-paths.sh

if [ -z "$SKYRIM_LIBRARY" ]; then
    say "Skyrim Special Edition is not installed in any Steam library. Install it in Steam first."
    pause_window
    exit 1
fi
say "Found Skyrim Special Edition in $SKYRIM_LIBRARY"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition"

CC_BACKUP="$HOME/.Cyphs/SteamDeckSTR-master/CC Backup/"

FILES_TO_BACKUP=("ccBGSSSE001-Fish.bsa" "ccBGSSSE001-Fish.esm" "ccBGSSSE025-AdvDSGS.bsa" "ccBGSSSE025-AdvDSGS.esm" "ccBGSSSE037-Curios.bsa" "ccBGSSSE037-Curios.esl" "ccQDRSSE001-SurvivalMode.bsa" "ccQDRSSE001-SurvivalMode.esl")

say "Setting up Skyrim Together Reborn..."

# Remove and back up CC content
mkdir -p "$CC_BACKUP"
for FILE in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "${SKYRIM_DIR}Data/${FILE}" ]; then
        echo "CC content found, removing ${FILE} and saving to CC Backup"
        mv "${SKYRIM_DIR}Data/${FILE}" "$CC_BACKUP"
    fi
done

str_setup() {
    if [ -d "$1" ] && [ -d "$2" ] && [ -f "${2}/SkyrimTogether.exe" ] && [ -f "${1}SkyrimSELauncher.exe" ]; then
        echo "Contents of SKYRIM_TOGETHER_PATH:"
        ls "$2"
        echo "Current directory: $(pwd)"

        echo "Renaming launcher (if needed)"
        # A real launcher here means a fresh install or a game update put it back
        if [ ! -L "${1}SkyrimSELauncher.exe" ]; then
            mv -f "${1}SkyrimSELauncher.exe" "${1}_SkyrimSELauncher.exe" || echo "Launcher rename failed"
        fi

        echo "Symlinking SkyrimTogether.exe"
        if [ ! -L "${1}SkyrimSELauncher.exe" ]; then
            ln -s "${2}/SkyrimTogether.exe" "${1}SkyrimSELauncher.exe" || echo "Failed to create launcher symlink"
        fi

        echo "Removing links to files older STR versions shipped"
        find "$1" -path "${1}Data" -prune -o -xtype l -lname "*SkyrimTogetherReborn*" -print -exec rm -f {} \;

        echo "Symlinking mod content"
        cd "${2}"
        # Recreate the folder layout first so empty folders (like resources) exist too
        find . -mindepth 1 -type d -exec bash -c 'mkdir -p "$1${0#./}"' {} "$1" \;
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

if [ ! -f "${SKYRIM_DIR}Data/SkyrimTogetherReborn/SkyrimTogether.exe" ]; then
    say "Skyrim Together Reborn was not found in the game's Data folder. Install it in Vortex first, then run STR Post-Deploy again."
    pause_window
    exit 1
fi
str_setup "$SKYRIM_DIR" "${SKYRIM_DIR}Data/SkyrimTogetherReborn"

# Let Vortex use the game's own INI files and saves
~/.Cyphs/SteamDeckSTR-master/vortex/link-my-games.sh

# Vortex 2.x needs Steam's library list inside its own prefix
python3 ~/.Cyphs/SteamDeckSTR-master/vortex/link-steam-libraries.py "$STEAM_ROOT/steamapps/libraryfolders.vdf" "$HOME/.vortex-linux/compatdata/pfx" || true

# Give the game its own copy of Vortex's plugin list (a link would let the game rewrite
# Vortex's file, which makes Vortex ask about "Plugin list changed outside Vortex"),
# and make sure the Skyrim Together Reborn plugins are enabled in that copy
if [ -d "$SKYRIM_APPDATA" ] && [ -f "$APPDATA_VORTEX/plugins.txt" ]; then
    echo "Copying plugins.txt and loadorder.txt from Vortex"
    rm -f "${SKYRIM_APPDATA}Plugins.txt" "${SKYRIM_APPDATA}loadorder.txt"
    cp "$APPDATA_VORTEX/plugins.txt" "${SKYRIM_APPDATA}Plugins.txt"
    if [ -f "$APPDATA_VORTEX/loadorder.txt" ]; then
        cp "$APPDATA_VORTEX/loadorder.txt" "${SKYRIM_APPDATA}loadorder.txt"
    fi
    python3 - "${SKYRIM_APPDATA}Plugins.txt" "${SKYRIM_DIR}Data" <<'EOF'
import os
import sys

plugins_txt, data_dir = sys.argv[1], sys.argv[2]
str_plugins = sorted(f for f in os.listdir(data_dir) if f.lower().startswith("skyrimtogether") and f.lower().endswith(".esp"))

with open(plugins_txt, encoding="utf-8") as f:
    lines = f.read().splitlines()

for plugin in str_plugins:
    for i, line in enumerate(lines):
        if line.lstrip("*").strip().lower() == plugin.lower():
            lines[i] = "*" + plugin
            break
    else:
        lines.append("*" + plugin)

with open(plugins_txt, "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")
EOF
else
    say "Run Skyrim Special Edition once through Steam and install your mods in Vortex, then run STR Post-Deploy again."
fi

# Add registry keys so Skyrim Together Reborn can find SkyrimSE.exe
USER_REG="${SKYRIM_COMPATDATA}pfx/user.reg"
if [ -f "$USER_REG" ]; then
    # Z: is the Linux root in Proton, every separator is written as four backslashes like before
    WIN_DIR="$(python3 -c 'import sys; print("Z:" + sys.argv[1].rstrip("/").replace("/", "\\\\\\\\"))' "$SKYRIM_DIR")"
    SEP='\\\\'
    {
        echo "[Software\\\\TiltedPhoques\\\\TiltedEvolution\\\\Skyrim Special Edition] $(date +%s)"
        echo "\"TitleExe\"=\"${WIN_DIR}${SEP}SkyrimSE.exe\""
        echo "\"TitlePath\"=\"${WIN_DIR}\""
    } >> "$USER_REG"
fi

# GE-Proton starts skse64_loader.exe instead of the launcher when SKSE is installed,
# which would skip STR (STR loads SKSE itself), so replace that fix with one that knows STR
mkdir -p ~/.config/protonfixes/localfixes
cp ~/.Cyphs/SteamDeckSTR-master/vortex/protonfixes/489830.py ~/.config/protonfixes/localfixes/489830.py

# Restart Steam
say "Restarting Steam, please wait..."
steam -shutdown || true
while pgrep -x "steam" > /dev/null; do sleep 1; done

# F3 (debug UI) and F4 (reveal players) only work under Proton 10 when Wine thinks it runs
# game 302190, which turns off a Proton hack that hides those key presses from STR
python3 ~/.Cyphs/SteamDeckSTR-master/vortex/set-launch-option.py add "$STEAM_ROOT" "$SKYRIM_APPID" "SteamGameId=302190" || echo "Could not set the launch option for F3 and F4."

nohup steam > /dev/null 2>&1 &

say ""
say "Done! You can play Skyrim Together Reborn from Steam now."
sleep 5
