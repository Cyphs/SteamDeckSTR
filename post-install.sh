#!/usr/bin/env bash
set -euxo pipefail

chmod +x ~/.Cyphs/SteamDeckSTR-master/vortex/*.sh

ln -sf ~/.Cyphs/SteamDeckSTR-master/update.desktop ~/Desktop/Cyphs-update.desktop

if [ ! -f "$HOME/.local/share/applications/vortex.desktop" ]; then
    echo "Creating Vortex install desktop shortcut..."
    ln -s ~/.Cyphs/SteamDeckSTR-master/vortex/install-vortex.desktop ~/Desktop/install-vortex.desktop || true
else
    echo "Creating Vortex desktop shortcuts..."
    ln -sf ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-post-deploy.desktop ~/Desktop/
    ln -sf ~/.Cyphs/SteamDeckSTR-master/vortex/Undo-STR.desktop ~/Desktop/

    # vortex-linux is no longer used, Vortex now runs through umu-launcher
    rm -f ~/.Cyphs/SteamDeckSTR-master/vortex/vortex-linux

    echo "Updating umu-launcher..."
    ~/.Cyphs/SteamDeckSTR-master/vortex/install-umu.sh

    echo "Updating GE-Proton..."
    ~/.Cyphs/SteamDeckSTR-master/vortex/install-proton.sh

    # Make sure the Vortex shortcut launches through umu-launcher
    cp ~/.Cyphs/SteamDeckSTR-master/vortex/vortex.desktop ~/.local/share/applications/
    ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/
    update-desktop-database ~/.local/share/applications || true

    # Let Vortex use the game's own INI files and saves
    ~/.Cyphs/SteamDeckSTR-master/vortex/link-my-games.sh
fi

