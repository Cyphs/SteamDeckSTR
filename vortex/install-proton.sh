#!/usr/bin/env bash
set -euxo pipefail

source ~/.Cyphs/SteamDeckSTR-master/vortex/versions.sh

PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$PROTON_BUILD/$PROTON_ARCHIVE"

# Selected for Skyrim in Steam's Compatibility settings (Vortex runs on umu's own Proton)
if [ ! -f "$COMPAT_DIR/$PROTON_DIR/proton" ]; then
    echo "Installing $PROTON_BUILD..."
    mkdir -p "$COMPAT_DIR"
    cd "$COMPAT_DIR"
    rm -rf "$PROTON_DIR"
    wget -O "$PROTON_BUILD.tar.gz" "$PROTON_URL"
    tar -xf "$PROTON_BUILD.tar.gz"
    rm "$PROTON_BUILD.tar.gz"
fi
