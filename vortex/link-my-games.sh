#!/usr/bin/env bash
# Vortex and Skyrim run in separate Proton prefixes. Link Vortex's
# Documents/My Games/Skyrim Special Edition to the game's own folder so Vortex
# sees the real Skyrim.ini, SkyrimPrefs.ini and saves instead of its own copies.
set -eo pipefail

source ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-paths.sh

VORTEX_USER="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser"

if [ -z "$SKYRIM_LIBRARY" ] || [ ! -d "$VORTEX_USER" ]; then
    exit 0
fi

GAME_MY_GAMES="${SKYRIM_COMPATDATA}pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition"
VORTEX_MY_GAMES="$VORTEX_USER/Documents/My Games/Skyrim Special Edition"

# Vortex keeps .base/.baked copies of the INIs it has seen, so only link before
# Vortex has managed the game. An existing Vortex setup keeps its own folder.
if [ -d "$VORTEX_MY_GAMES" ] && [ ! -L "$VORTEX_MY_GAMES" ]; then
    exit 0
fi

mkdir -p "$(dirname "$VORTEX_MY_GAMES")"
ln -sfn "$GAME_MY_GAMES" "$VORTEX_MY_GAMES"
echo "Vortex now uses the game's My Games folder"
