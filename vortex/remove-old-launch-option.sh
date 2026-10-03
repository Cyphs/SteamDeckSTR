#!/usr/bin/env bash
# Older versions of STR Post-Deploy added SteamGameId=302190 to Skyrim's launch options
# for the F3 and F4 keys, but it makes Game Mode show a black screen. Removes it once,
# so it can still be added by hand for Desktop mode (see the README). Steam must be closed.
set -euo pipefail

MARKER="$HOME/.Cyphs/.launch-option-removed"
[ -f "$MARKER" ] && exit 0

source ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-paths.sh
python3 ~/.Cyphs/SteamDeckSTR-master/vortex/set-launch-option.py remove "$STEAM_ROOT" "$SKYRIM_APPID" "SteamGameId=302190" || true
touch "$MARKER"
