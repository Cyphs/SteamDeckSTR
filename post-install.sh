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

    source ~/.Cyphs/SteamDeckSTR-master/vortex/versions.sh
    export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx"
    INSTALLED_VORTEX="$(python3 ~/.Cyphs/SteamDeckSTR-master/vortex/vortex-version.py "$VORTEX_DIR/resources/app.asar")"
    if [ -z "$INSTALLED_VORTEX" ]; then
        INSTALLED_VORTEX="$(python3 ~/.Cyphs/SteamDeckSTR-master/vortex/vortex-version.py "$OLD_VORTEX_DIR/resources/app.asar")"
    fi

    # Older installs have Vortex 1.x, upgrade them (mods and settings are kept).
    # A newer Vortex is left alone.
    if [ -n "$INSTALLED_VORTEX" ] && [ "$(printf '%s\n' "$INSTALLED_VORTEX" "$VORTEX_VERSION" | sort -V | head -1)" != "$VORTEX_VERSION" ]; then
        echo "Upgrading Vortex $INSTALLED_VORTEX to $VORTEX_VERSION..."
        cd ~/.Cyphs/SteamDeckSTR-master/vortex/
        wget -O dotnet-runtime.exe "$DOTNET_URL"
        "$UMU_DIR/umu-run" dotnet-runtime.exe /q
        wget -O "vortex-setup-$VORTEX_VERSION.exe" "https://github.com/Nexus-Mods/Vortex/releases/download/v$VORTEX_VERSION/vortex-setup-$VORTEX_VERSION.exe"
        "$UMU_DIR/umu-run" "vortex-setup-$VORTEX_VERSION.exe" /S
        rm -f "vortex-setup-$VORTEX_VERSION.exe" dotnet-runtime.exe
    fi

    source ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-paths.sh
    # Vortex 2.x needs Steam's library list inside its own prefix
    python3 ~/.Cyphs/SteamDeckSTR-master/vortex/link-steam-libraries.py "$STEAM_ROOT/steamapps/libraryfolders.vdf" "$HOME/.vortex-linux/compatdata/pfx" || true

    # Keep Vortex from updating itself past the tested version, and enable new plugins
    python3 ~/.Cyphs/SteamDeckSTR-master/vortex/preset-vortex.py "$WINEPREFIX/drive_c/sdstr-preset.bat"
    "$UMU_DIR/umu-run" cmd.exe /c "C:\\sdstr-preset.bat" || echo "Could not update Vortex settings."
    rm -f "$WINEPREFIX/drive_c/sdstr-preset.bat"

    # Switch Skyrim to the new GE-Proton in Steam (Steam has to be closed to change it)
    source ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-paths.sh
    if pgrep -x steam > /dev/null; then
        echo "Restarting Steam to select $PROTON_DIR for Skyrim. Please wait..."
        steam -shutdown || true
        while pgrep -x steam > /dev/null; do sleep 1; done
        STEAM_WAS_RUNNING=1
    fi
    python3 ~/.Cyphs/SteamDeckSTR-master/vortex/set-compat-tool.py "$STEAM_ROOT/config/config.vdf" "$SKYRIM_APPID" "$PROTON_DIR" || echo "Could not select $PROTON_DIR for Skyrim, pick it in Steam instead."
    if [ -n "${STEAM_WAS_RUNNING:-}" ]; then
        nohup steam > /dev/null 2>&1 &
    fi
fi

