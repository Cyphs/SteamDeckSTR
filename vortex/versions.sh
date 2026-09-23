#!/usr/bin/env bash
# Pinned versions shared by the install, update and launch scripts
UMU_VERSION="1.4.4"
VORTEX_VERSION="1.15.2"
# GE-Proton 11 (Wine 11) closes Skyrim Together Reborn 1.8 right after launch, stay on 10
PROTON_BUILD="GE-Proton10-34"
# Release file, and the folder it unpacks to in compatibilitytools.d (also the name shown in Steam)
PROTON_ARCHIVE="$PROTON_BUILD.tar.gz"
PROTON_DIR="$PROTON_BUILD"
DOTNET_URL="https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.13/windowsdesktop-runtime-9.0.13-win-x64.exe"

UMU_DIR="$HOME/.Cyphs/umu"
COMPAT_DIR="$HOME/.steam/root/compatibilitytools.d"
