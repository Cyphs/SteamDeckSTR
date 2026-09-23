#!/usr/bin/env bash
set -euxo pipefail

source ~/.Cyphs/SteamDeckSTR-master/vortex/versions.sh

UMU_URL="https://github.com/Open-Wine-Components/umu-launcher/releases/download/$UMU_VERSION/umu-launcher-$UMU_VERSION-zipapp.tar"

if umu_up_to_date; then
    echo "umu-launcher $UMU_VERSION is already installed."
    exit 0
fi

echo "Installing umu-launcher $UMU_VERSION..."
mkdir -p "$UMU_DIR"
cd "$UMU_DIR"
python3 ~/.Cyphs/SteamDeckSTR-master/vortex/download.py "$UMU_URL" "umu-launcher-$UMU_VERSION-zipapp.tar"
tar --strip-components=1 -xf "umu-launcher-$UMU_VERSION-zipapp.tar"
chmod +x ./*
rm "umu-launcher-$UMU_VERSION-zipapp.tar"
