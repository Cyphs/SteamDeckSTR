#!/usr/bin/env bash
set -euxo pipefail

source ~/.Cyphs/SteamDeckSTR-master/vortex/versions.sh

UMU_URL="https://github.com/Open-Wine-Components/umu-launcher/releases/download/$UMU_VERSION/umu-launcher-$UMU_VERSION-zipapp.tar"

echo "Installing umu-launcher $UMU_VERSION..."
mkdir -p "$UMU_DIR"
cd "$UMU_DIR"
wget -O "umu-launcher-$UMU_VERSION-zipapp.tar" "$UMU_URL"
tar --strip-components=1 -xf "umu-launcher-$UMU_VERSION-zipapp.tar"
chmod +x ./*
rm "umu-launcher-$UMU_VERSION-zipapp.tar"
