#!/usr/bin/env python3
# Writes a batch file that presets Vortex settings with Vortex's own --set
# command line switches, so the game folder, game store, staging folder and
# hardlink deployment don't have to be picked by hand, and updates stay off.
# Usage: preset-vortex.py <batch file> [drive letter of the Steam library with Skyrim]
import json
import sys

batch, drive = sys.argv[1], (sys.argv[2] if len(sys.argv) > 2 else "")

settings = [
    ("settings.update.channel", "none"),
    # Vortex leaves new plugins disabled by default, which would leave
    # SkyrimTogether.esp off after installing Skyrim Together Reborn
    ("settings.plugins.autoEnable", True),
]
if drive:
    settings += [
        # Same fields Vortex saves when the game folder is picked by hand
        ("settings.gameMode.discovered.skyrimse.path", f"{drive}:\\Skyrim Special Edition"),
        ("settings.gameMode.discovered.skyrimse.executable", "SkyrimSE.exe"),
        ("settings.gameMode.discovered.skyrimse.environment.SteamAPPId", "489830"),
        ("settings.gameMode.discovered.skyrimse.pathSetManually", True),
        ("settings.gameMode.discovered.skyrimse.store", "steam"),
        ("settings.gameMode.discovered.skyrimse.hidden", False),
        # Staging folder must be on the same drive as the game for hardlinks
        ("settings.mods.installPath.skyrimse", f"{drive}:\\Vortex Mods\\{{game}}"),
        ("settings.mods.activator.skyrimse", "hardlink_activator"),
    ]


def win_arg(text):
    """Quote one argument for the Windows command line."""
    out, backslashes = '"', 0
    for ch in text:
        if ch == "\\":
            backslashes += 1
            continue
        if ch == '"':
            out += "\\" * (backslashes * 2 + 1) + '"'
        else:
            out += "\\" * backslashes + ch
        backslashes = 0
    return out + "\\" * (backslashes * 2) + '"'


# Fresh installs of Vortex 2.x go to Program Files\Vortex, upgrades of 1.x stay in the old folder
lines = [
    "@echo off",
    'if exist "C:\\Program Files\\Vortex\\Vortex.exe" (cd /d "C:\\Program Files\\Vortex") else (cd /d "C:\\Program Files\\Black Tree Gaming Ltd\\Vortex")',
]
for key, value in settings:
    # Vortex 2.x stores the value text as given, so it is written as JSON.
    # One --set per run, and start /wait keeps the batch file running after it.
    lines.append(f'start "" /wait Vortex.exe --set {win_arg(f"{key}={json.dumps(value)}")}')

with open(batch, "w", newline="") as f:
    f.write("\r\n".join(lines) + "\r\n")
