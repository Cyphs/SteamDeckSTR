#!/usr/bin/env bash
set -euxo pipefail

source ~/.Cyphs/SteamDeckSTR-master/vortex/versions.sh

PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$PROTON_BUILD/$PROTON_ARCHIVE"

# Selected for Skyrim in Steam's Compatibility settings (Vortex runs on umu's own Proton)
if proton_up_to_date; then
    echo "$PROTON_BUILD is already installed."
    exit 0
fi

echo "Installing $PROTON_BUILD..."
mkdir -p "$COMPAT_DIR"
cd "$COMPAT_DIR"
rm -rf "$PROTON_DIR"
python3 ~/.Cyphs/SteamDeckSTR-master/vortex/download.py "$PROTON_URL" "$PROTON_ARCHIVE"
tar -xf "$PROTON_ARCHIVE"
rm "$PROTON_ARCHIVE"
