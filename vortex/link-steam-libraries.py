#!/usr/bin/env python3
# Vortex 2.x reads Steam's library list from the Steam folder inside its own Wine
# prefix (C:\Program Files (x86)\Steam\config\libraryfolders.vdf) and stops with an
# "unrecoverable error" when the file is missing. Writes a copy of the real list there,
# with the Linux library paths turned into Wine paths (Z: is the Linux root).
# Usage: link-steam-libraries.py <real libraryfolders.vdf> <Wine prefix>
import os
import re
import sys

source, prefix = sys.argv[1], sys.argv[2]

with open(source, encoding="utf-8") as f:
    text = f.read()


def to_wine(match):
    linux_path = match.group(2).replace("\\\\", "\\")
    wine_path = "Z:" + linux_path.replace("/", "\\")
    return match.group(1) + wine_path.replace("\\", "\\\\") + '"'


text = re.sub(r'("path"\s+")((?:\\.|[^"\\])*)"', to_wine, text)

config = os.path.join(prefix, "drive_c", "Program Files (x86)", "Steam", "config")
os.makedirs(config, exist_ok=True)
with open(os.path.join(config, "libraryfolders.vdf"), "w", encoding="utf-8") as f:
    f.write(text)
