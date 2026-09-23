#!/usr/bin/env bash
set -euo pipefail

source ~/.Cyphs/SteamDeckSTR-master/vortex/quiet.sh update-steamdeckstr
set -x

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

    source ~/.Cyphs/SteamDeckSTR-master/vortex/versions.sh

    if ! umu_up_to_date; then
        say "Updating umu-launcher..."
        ~/.Cyphs/SteamDeckSTR-master/vortex/install-umu.sh
        UPDATED=1
    fi

    if ! proton_up_to_date; then
        say "Downloading $PROTON_BUILD (about 500 MB)..."
        ~/.Cyphs/SteamDeckSTR-master/vortex/install-proton.sh
        UPDATED=1
    fi

    # Make sure the Vortex shortcut launches through umu-launcher
    cp ~/.Cyphs/SteamDeckSTR-master/vortex/vortex.desktop ~/.local/share/applications/
    ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/
    update-desktop-database ~/.local/share/applications || true

    # Let Vortex use the game's own INI files and saves
    ~/.Cyphs/SteamDeckSTR-master/vortex/link-my-games.sh

    export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx"
    INSTALLED_VORTEX="$(python3 ~/.Cyphs/SteamDeckSTR-master/vortex/vortex-version.py "$VORTEX_DIR/resources/app.asar")"
    if [ -z "$INSTALLED_VORTEX" ]; then
        INSTALLED_VORTEX="$(python3 ~/.Cyphs/SteamDeckSTR-master/vortex/vortex-version.py "$OLD_VORTEX_DIR/resources/app.asar")"
    fi

    # Older installs have Vortex 1.x, upgrade them (mods and settings are kept).
    # A newer Vortex is left alone.
    if [ -n "$INSTALLED_VORTEX" ] && [ "$(printf '%s\n' "$INSTALLED_VORTEX" "$VORTEX_VERSION" | sort -V | head -1)" != "$VORTEX_VERSION" ]; then
        say "Upgrading Vortex $INSTALLED_VORTEX to $VORTEX_VERSION (this takes a few minutes)..."
        wait_for_vortex_closed
        cd ~/.Cyphs/SteamDeckSTR-master/vortex/
        python3 ./download.py "$DOTNET_URL" dotnet-runtime.exe
        python3 ./download.py "https://github.com/Nexus-Mods/Vortex/releases/download/v$VORTEX_VERSION/vortex-setup-$VORTEX_VERSION.exe" "vortex-setup-$VORTEX_VERSION.exe"
        say "Installing Vortex $VORTEX_VERSION..."
        "$UMU_DIR/umu-run" dotnet-runtime.exe /q
        "$UMU_DIR/umu-run" "vortex-setup-$VORTEX_VERSION.exe" /S
        rm -f "vortex-setup-$VORTEX_VERSION.exe" dotnet-runtime.exe
        UPDATED=1
    fi

    source ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-paths.sh
    # Vortex 2.x needs Steam's library list inside its own prefix
    python3 ~/.Cyphs/SteamDeckSTR-master/vortex/link-steam-libraries.py "$STEAM_ROOT/steamapps/libraryfolders.vdf" "$HOME/.vortex-linux/compatdata/pfx" || true

    # Keep Vortex from updating itself past the tested version, and enable new plugins.
    # Skipped when these exact settings were already applied.
    PRESET_BAT="$WINEPREFIX/drive_c/sdstr-preset.bat"
    PRESET_DONE="$HOME/.vortex-linux/sdstr-preset-applied.bat"
    python3 ~/.Cyphs/SteamDeckSTR-master/vortex/preset-vortex.py "$PRESET_BAT"
    if ! cmp -s "$PRESET_BAT" "$PRESET_DONE"; then
        say "Updating Vortex settings..."
        wait_for_vortex_closed
        if timeout 600 "$UMU_DIR/umu-run" cmd.exe /c "C:\\sdstr-preset.bat"; then
            cp "$PRESET_BAT" "$PRESET_DONE"
        else
            echo "Could not update Vortex settings."
        fi
        UPDATED=1
    fi
    rm -f "$PRESET_BAT"

    # Switch Skyrim to the new GE-Proton in Steam (Steam has to be closed to change it)
    source ~/.Cyphs/SteamDeckSTR-master/vortex/skyrim-paths.sh
    CONFIG_VDF="$STEAM_ROOT/config/config.vdf"
    if [ -n "$SKYRIM_LIBRARY" ] && ! python3 ~/.Cyphs/SteamDeckSTR-master/vortex/set-compat-tool.py --check "$CONFIG_VDF" "$SKYRIM_APPID" "$PROTON_DIR"; then
        if pgrep -x steam > /dev/null; then
            say "Restarting Steam, please wait..."
            steam -shutdown || true
            while pgrep -x steam > /dev/null; do sleep 1; done
            STEAM_WAS_RUNNING=1
        fi
        python3 ~/.Cyphs/SteamDeckSTR-master/vortex/set-compat-tool.py "$CONFIG_VDF" "$SKYRIM_APPID" "$PROTON_DIR" || echo "Could not select $PROTON_DIR for Skyrim, pick it in Steam instead."
        if [ -n "${STEAM_WAS_RUNNING:-}" ]; then
            nohup steam > /dev/null 2>&1 &
        fi
        UPDATED=1
    fi

    say ""
    if [ -n "${UPDATED:-}" ]; then
        say "Done! SteamDeckSTR is updated."
    else
        say "Everything was already up to date."
    fi
    say ""
    say "Next steps:"
    say "1. In Vortex, make sure you have the latest Skyrim Together Reborn ($STR_VERSION) and"
    say "   Address Library ($ADDRESS_LIBRARY_VERSION). If not, download them from Nexus Mods,"
    say "   install them in Vortex and choose Replace when Vortex asks about the old version."
    say "2. Run STR Post-Deploy on the desktop (again after any change to your mods in Vortex)."
    say ""
    pause_window
    exit 0
fi

say ""
say "Done! SteamDeckSTR is installed. Now run Install Vortex on the desktop."
sleep 5
