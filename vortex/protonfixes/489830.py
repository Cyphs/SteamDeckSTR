"""Skyrim Special Edition fix for GE-Proton, installed by SteamDeckSTR.

A local fix in ~/.config/protonfixes/localfixes replaces GE-Proton's own one. It does the
same thing (start skse64_loader.exe instead of the launcher when SKSE is installed),
except while Skyrim Together Reborn is set up: then SkyrimSELauncher.exe is STR's
launcher, which loads SKSE itself, and starting SKSE's loader would skip STR.
"""

import os

from protonfixes import util


def main() -> None:
    # Mod Organizer 2 has its own redirector
    if os.path.exists('modorganizer2'):
        return

    # STR Post-Deploy links SkyrimSELauncher.exe to SkyrimTogether.exe
    launcher = 'SkyrimSELauncher.exe'
    if os.path.islink(launcher) and os.path.realpath(launcher).lower().endswith('skyrimtogether.exe'):
        return

    if os.path.isfile('skse64_loader.exe'):
        util.replace_command(launcher, 'skse64_loader.exe')
