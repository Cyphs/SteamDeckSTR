#!/usr/bin/env bash
# Pinned versions shared by the install, update and launch scripts
UMU_VERSION="1.4.4"
VORTEX_VERSION="2.7.0"
# Fresh Vortex 2.x installs go here, upgrades from 1.x stay in "Black Tree Gaming Ltd\Vortex"
VORTEX_DIR="$HOME/.vortex-linux/compatdata/pfx/drive_c/Program Files/Vortex"
OLD_VORTEX_DIR="$HOME/.vortex-linux/compatdata/pfx/drive_c/Program Files/Black Tree Gaming Ltd/Vortex"
# GE-Proton 11 (Wine 11) closes Skyrim Together Reborn 1.8 right after launch, stay on 10
PROTON_BUILD="GE-Proton10-34"
# Release file, and the folder it unpacks to in compatibilitytools.d (also the name shown in Steam)
PROTON_ARCHIVE="$PROTON_BUILD.tar.gz"
PROTON_DIR="$PROTON_BUILD"
DOTNET_URL="https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.13/windowsdesktop-runtime-9.0.13-win-x64.exe"

UMU_DIR="$HOME/.Cyphs/umu"
COMPAT_DIR="$HOME/.steam/root/compatibilitytools.d"

# Mod versions the scripts were tested with, shown as a reminder after updating
STR_VERSION="1.8.2"
ADDRESS_LIBRARY_VERSION="All in One v13"

umu_up_to_date() {
    "$UMU_DIR/umu-run" --version 2>/dev/null | grep -q "version $UMU_VERSION "
}

proton_up_to_date() {
    [ -f "$COMPAT_DIR/$PROTON_DIR/proton" ]
}
