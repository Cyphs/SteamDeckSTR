#!/usr/bin/env bash
set -euxo pipefail

ln -sf ~/.Cyphs/steam-deck-master/update.desktop ~/Desktop/Cyphs-update.desktop

if [ ! -f "$HOME/.local/share/applications/vortex.desktop" ]; then
    echo "Creating Vortex install desktop shortcut..."
    ln -s ~/.Cyphs/steam-deck-master/vortex/install-vortex.desktop ~/Desktop/install-vortex.desktop || true
else
    echo "Creating Vortex desktop shortcuts..."
    ln -sf ~/.Cyphs/steam-deck-master/vortex/skyrim-post-deploy.desktop ~/Desktop/

    VORTEX_LINUX="v1.3.4"
    PROTON_BUILD="GE-Proton8-27"

    PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$PROTON_BUILD/$PROTON_BUILD.tar.gz"

    echo "Updating vortex-linux..."
    pushd ~/.Cyphs/steam-deck-master/vortex/
    rm -rf vortex-linux || true
    wget https://github.com/pikdum/vortex-linux/releases/download/$VORTEX_LINUX/vortex-linux
    chmod +x vortex-linux
    popd

    ~/.Cyphs/steam-deck-master/vortex/vortex-linux setupVortexDesktop

    if [ ! -d "$HOME/.vortex-linux/proton-builds/$PROTON_BUILD" ]; then
        echo "Removing old Proton builds..."
        rm -rf $HOME/.vortex-linux/proton-builds/*
        echo "Upgrading Proton to $PROTON_BUILD..."
        ~/.Cyphs/steam-deck-master/vortex/vortex-linux downloadProton "$PROTON_URL"
        ~/.Cyphs/steam-deck-master/vortex/vortex-linux setProton "$PROTON_BUILD"
    fi
fi

mkdir -p /run/media/mmcblk0p1/vortex-downloads || true
