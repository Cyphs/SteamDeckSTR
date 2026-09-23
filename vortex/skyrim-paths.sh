#!/usr/bin/env bash
# Finds the Steam library that has Skyrim Special Edition installed (internal storage,
# SD card, with or without a SteamLibrary folder) using Steam's own libraryfolders.vdf.
# Sets SKYRIM_LIBRARY, SKYRIM_DIR, SKYRIM_COMPATDATA and SKYRIM_APPDATA, or leaves
# SKYRIM_LIBRARY empty if the game isn't installed.

SKYRIM_APPID="489830"
STEAM_ROOT="$HOME/.steam/root"
LIBRARY_FOLDERS="$STEAM_ROOT/steamapps/libraryfolders.vdf"

SKYRIM_LIBRARY=""
if [ -f "$LIBRARY_FOLDERS" ]; then
    SKYRIM_LIBRARY="$(python3 - "$LIBRARY_FOLDERS" "$SKYRIM_APPID" <<'EOF'
import re
import sys

text = open(sys.argv[1], encoding="utf-8").read()
paths = list(re.finditer(r'"path"\s+"((?:\\.|[^"\\])*)"', text))
for i, match in enumerate(paths):
    # Each library's apps are listed after its path and before the next library's path
    end = paths[i + 1].start() if i + 1 < len(paths) else len(text)
    if re.search(r'"' + sys.argv[2] + r'"\s+"', text[match.end():end]):
        print(match.group(1).replace("\\\\", "\\"))
        break
EOF
)"
fi

SKYRIM_DIR=""
SKYRIM_COMPATDATA=""
SKYRIM_APPDATA=""
if [ -n "$SKYRIM_LIBRARY" ]; then
    SKYRIM_DIR="$SKYRIM_LIBRARY/steamapps/common/Skyrim Special Edition/"
    SKYRIM_COMPATDATA="$SKYRIM_LIBRARY/steamapps/compatdata/$SKYRIM_APPID/"
    SKYRIM_APPDATA="${SKYRIM_COMPATDATA}pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
fi
